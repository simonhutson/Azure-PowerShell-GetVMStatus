<#

.SYNOPSIS
Retrieve the status of all Azure Virtual Machines across all Subscriptions associated with a specific Azure AD Tenant

.NOTES
Make sure you have the correct versions of PowerShell 5.x installed, by running this command:

    $PSVersionTable.PSVersion

If the AZ PowerShell module is not installed, then you can run these PowerShell commands in an eleveated shell:

    Set-ExecutionPolicy -Scope "CurrentUser" -ExecutionPolicy "Bypass" -ErrorAction SilentlyContinue -Confirm -Force -Verbose
    Find-PackageProvider -Name "Nuget" -Force -Verbose | Install-PackageProvider -Scope "CurrentUser" -Force -Confirm -Verbose
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -PackageManagementProvider "Nuget" -Verbose
    Install-Module -Name "PowerShellGet" -Repository "PSGallery" -Scope "CurrentUser" -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Install-Module -Name "Az" -Repository "PSGallery" -Scope "CurrentUser" -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Install-Module -Name "Az.ResourceGraph" -Repository "PSGallery" -Scope "CurrentUser" -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose

    https://docs.microsoft.com/powershell/azure/install-az-ps
#>

Import-Module .\Modules\Login-Azure.ps1
Import-Module .\Modules\Get-ReservedVMInstanceFamilies.ps1
Import-Module .\Modules\Join-Object.ps1

$ErrorActionPreference = 'Stop'
$DateTime = Get-Date -f 'yyyy-MM-dd HHmmss'

# Call Login-Azure module
$Account = Login-Azure

# Get list of Subscriptions associated with this Azure AD Tenant, for which this User has access
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure Subscriptions for this Azure AD Tenant"
$AllSubscriptions = @(Get-AzSubscription -TenantId $Account.Context.Tenant.Id)
Write-Host

if ($AllSubscriptions.Count -gt 1) # User has access to more than one Azure Subscription
{
    $SelectedSubscriptions = $AllSubscriptions | Out-GridView -Title "Select the Azure Subscriptions you wish to use..." -OutputMode Multiple
}
elseif ($AllSubscriptions.Count -eq 1) # User has access to only one Azure Subscription
{
    $SelectedSubscriptions = @($AllSubscriptions.Item(0))
}
else # User has access to no Azure Subscription
{
    Return
}

# Get VM Sizes
$VMSizes = @()
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure VM Sizes across all locations"

# Get list of Azure Locations associated with this Subscription, for which this User has access and that support VMs
$Locations = Get-AzLocation | Where-Object { $_.Providers -eq "Microsoft.Compute" }

# Loop through each Azure Location to retrieve a complete list of VM Sizes
foreach ($Location in $Locations)
{
    try
    {
        $VMSizes += Get-AzVMSize -Location $($Location.Location)
        Write-Host -NoNewline "."
    }
    catch
    {
        #Do Nothing
    }
}
$VMSizes = $VMSizes | Select-Object -Unique Name, NumberOfCores, MemoryInMB, MaxDataDiskCount, OSDiskSizeInMB, ResourceDiskSizeInMB
Write-Host

# Call the Get-ReservedVMInstances module
$ReservedVMInstances = Get-ReservedVMInstanceFamilies

Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure Log Analytics Workspaces"
$LogAnalyticsWorkspaces = Search-AzGraph -First 5000 -Query "
extend WorkspaceSubscriptionId = tostring(split(id,'/',2)[0])
| extend WorkspaceResourceGroupName = tostring(split(id,'/',4)[0])
| extend WorkspaceSku = tostring(properties.sku.name)
| extend WorkspaceRetentionInDays = tostring(properties.retentionInDays)
| extend WorkspaceDailyQuotaGb = tostring(properties.workspaceCapping.dailyQuotaGb)
| extend WorkspaceId = tostring(properties.customerId)
| extend WorkspaceName = tostring(name)
| where type =~ 'microsoft.operationalinsights/workspaces'
| project WorkspaceSubscriptionId, WorkspaceResourceGroupName, WorkspaceName, WorkspaceId, WorkspaceSku, WorkspaceRetentionInDays, WorkspaceDailyQuotaGb
"

$WorkspaceSubscriptions = $AllSubscriptions `
| Select-Object -Property `
@{label = "WorkspaceSubscriptionId"; expression = { $_.Id } }, `
@{label = "WorkspaceSubscriptionName"; expression = { $_.Name } }

if ($LogAnalyticsWorkspaces)
{
    $LogAnalyticsWorkspaces = Join-Object -Left $LogAnalyticsWorkspaces -Right $WorkspaceSubscriptions -LeftJoinProperty WorkspaceSubscriptionId -RightJoinProperty WorkspaceSubscriptionId -Type AllInLeft -RightProperties WorkspaceSubscriptionName
}

Write-Host

# Loop through each Subscription
foreach ($Subscription in $SelectedSubscriptions)
{
    # Set the current Azure context
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Setting context for Subscription: $($Subscription.Name)"
    $null = Set-AzContext -SubscriptionId $Subscription -TenantId $Account.Context.Tenant.Id
    Write-Host

    # Get the status of all the ARM VMs in the current Subscription
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving status of ARM Virtual Machines in Subscription: $($Subscription.Name)"
    $VMStatuses = Get-AzVM -Status
    Write-Host

    # Get Authentication Access Token, for use with the Azure REST API
    $TokenCache = (Get-AzContext).TokenCache
    $Token = $TokenCache.ReadItems() | Where-Object { $_.TenantId -eq $Account.Context.Tenant.Id -and $_.DisplayableId -eq $Account.Context.Account.Id -and $_.Resource -eq "https://management.core.windows.net/" }
    $AccessToken = "Bearer " + $Token.AccessToken

    # Get the created & last updated date/time of all the ARM VMs in the current Subscription by calling the Azure REST API
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving created & last updated date/time of ARM Virtual Machines in Subscription: $($Subscription.Name)"
    $Headers = @{"Content-Type" = "application\json"; "Authorization" = "$AccessToken" }
    $VMRestProperties = Invoke-RestMethod -Method "Get" -Headers $Headers -Uri "https://management.azure.com/subscriptions/$($Subscription.Id)/resources?`$filter=resourcetype eq 'Microsoft.Compute/virtualMachines'&`$expand=createdTime,changedTime&api-version=2018-08-01" | Select-Object -ExpandProperty value
    Write-Host

    # Retrieve full details of all the ARM VMs in the current Subscription
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of ARM Virtual Machines in Subscription: $($Subscription.Name)"
    $VMObjects = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    extend ResourceId = id
    | extend ResourceGroup = toupper(resourceGroup)
    | extend VMName = toupper(name)
    | extend VMLocation = location
    | extend AvailabilitySet = toupper(split(properties.availabilitySet.id,'/',8)[0])
    | extend VMSize = properties.hardwareProfile.vmSize
    | extend ProvisioningState = properties.provisioningState
    | extend OSDiskType = iif(isnotnull(properties.storageProfile.osDisk.managedDisk),'Managed','Unmanged')
    | extend OSDiskStorageAccount = toupper(split(split(split(properties.storageProfile.osDisk.vhd.uri,'//',1)[0],'/',0)[0],'.',0)[0])
    | extend OSDiskSize = properties.storageProfile.osDisk.diskSizeGB
    | extend OSDiskCaching = properties.storageProfile.osDisk.caching
    | extend OSDiskStorageType = properties.storageProfile.osDisk.managedDisk.storageAccountType
    | extend DataDiskCount = array_length(properties.storageProfile.dataDisks)
    | extend OSType = properties.storageProfile.osDisk.osType
    | extend WindowsHybridBenefit = iif(properties.licenseType =~ 'Windows_Server','Enabled',iif(properties.storageProfile.osDisk.osType =~ 'Windows','Not Enabled','Not Supported'))
    | extend OSDiskCreateOption = properties.storageProfile.osDisk.createOption
    | extend ImagePublisher = properties.storageProfile.imageReference.publisher
    | extend ImageOffer = properties.storageProfile.imageReference.offer
    | extend ImageSku = properties.storageProfile.imageReference.sku
    | extend ImageVersion = properties.storageProfile.imageReference.version
    | extend NetworkInterface0 = toupper(split(properties.networkProfile.networkInterfaces[0].id,'/',8)[0])
    | extend NetworkInterface1 = toupper(split(properties.networkProfile.networkInterfaces[1].id,'/',8)[0])
    | extend NetworkInterface2 = toupper(split(properties.networkProfile.networkInterfaces[2].id,'/',8)[0])
    | extend NetworkInterface3 = toupper(split(properties.networkProfile.networkInterfaces[3].id,'/',8)[0])
    | extend BootDiagnostcsEnabled = iif(isnotnull(properties.diagnosticsProfile.bootDiagnostics),properties.diagnosticsProfile.bootDiagnostics.enabled,'False')
    | extend BootDiagnostcsStorageAccount = toupper(split(split(split(properties.diagnosticsProfile.bootDiagnostics.storageUri,'//',1)[0],'/',0)[0],'.',0)[0])
    | extend TagEnvironment = tostring(tags.Environment)
    | extend TagServiceTicketRequestID = tostring(tags.['Service Ticket Request ID'])
    | extend TagServiceOwner = tostring(tags.['Service Owner'])
    | extend TagServiceName = tostring(tags.['Service Name'])
    | where type =~ 'microsoft.compute/virtualmachines'
    | order by id asc
    | project ResourceId,ResourceGroup,VMName,VMLocation,AvailabilitySet,VMSize,ProvisioningState,OSDiskType,OSDiskStorageAccount,OSDiskSize,OSDiskCaching,OSDiskStorageType,DataDiskCount,OSType,WindowsHybridBenefit,OSDiskCreateOption,ImagePublisher,ImageOffer,ImageSku,ImageVersion,NetworkInterface0,NetworkInterface1,NetworkInterface2,NetworkInterface3,BootDiagnostcsEnabled,BootDiagnostcsStorageAccount,TagEnvironment,TagServiceTicketRequestID,TagServiceOwner,TagServiceName
    "
    Write-Host

    # Retrieve full details of all the ARM SQL VMs in the current Subscription
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of ARM SQL Virtual Machines in Subscription: $($Subscription.Name)"
    $SQLVMObjects = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    extend ResourceId = id
    | extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
    | extend VMName = toupper(tostring(split(id,'/',8)[0]))
    | extend SqlServerLicenseType = tostring(properties.sqlServerLicenseType)
    | extend SqlManagement = tostring(properties.sqlManagement)
    | extend SqlImageOffer = tostring(properties.sqlImageOffer)
    | extend SqlImageSku = tostring(properties.sqlImageSku)
    | where type =~ 'microsoft.sqlvirtualmachine/sqlvirtualmachines'
    | project ResourceId, ResourceGroup, VMName, location, SqlServerLicenseType, SqlManagement, SqlImageOffer, SqlImageSku
    "
    Write-Host


    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Virtual Machines Monioring Extensions in Subscription: $($Subscription.Name)"
    $VMMonitoringExtensions = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
    | extend VMName = toupper(tostring(split(id,'/',8)[0]))
    | extend VMMonitoringExtensionPublisher = tostring(properties.publisher)
    | extend VMMonitoringExtensionType = tostring(properties.type)
    | extend VMMonitoringExtensionVersion = tostring(properties.typeHandlerVersion)
    | extend VMMonitoringExtensionProvisioningState = tostring(properties.provisioningState)
    | extend WorkspaceId = tostring(properties.settings.workspaceId)
    | where type =~ 'microsoft.compute/virtualmachines/extensions'
    | where VMMonitoringExtensionPublisher =~ 'Microsoft.EnterpriseCloud.Monitoring'
    | project ResourceGroup, VMName, VMMonitoringExtensionPublisher, VMMonitoringExtensionType, VMMonitoringExtensionVersion, VMMonitoringExtensionProvisioningState, WorkspaceId
    "
    Write-Host

    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of SQL Server IaaS Agent Extensions in Subscription: $($Subscription.Name)"
    $SQLServerIaaSExtensions = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
    | extend VMName = toupper(tostring(split(id,'/',8)[0]))
    | extend SQLServerIaaSExtensionPublisher = tostring(properties.publisher)
    | extend SQLServerIaaSExtensionType = tostring(properties.type)
    | extend SQLServerIaaSExtensionVersion = tostring(properties.typeHandlerVersion)
    | extend SQLServerIaaSExtensionProvisioningState = tostring(properties.provisioningState)
    | where type =~ 'microsoft.compute/virtualmachines/extensions'
    | where SQLServerIaaSExtensionPublisher =~ 'Microsoft.SqlServer.Management'
    | project ResourceGroup, VMName, SQLServerIaaSExtensionPublisher, SQLServerIaaSExtensionType, SQLServerIaaSExtensionVersion, SQLServerIaaSExtensionProvisioningState
    "
    Write-Host

    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Network Interfaces in Subscription: $($Subscription.Name)"
    $NetworkInterfaces = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    extend NetworkInterface = toupper(name)
    | extend NetworkInterfaceEnableAcceleratedNetworking = tolower(properties.enableAcceleratedNetworking)
    | extend NetworkInterfacePrimary = tolower(iif(isnotnull(properties.primary),properties.primary,false))
    | where type =~ 'microsoft.network/networkinterfaces'
    "
    Write-Host



    if ($VMObjects)
    {
        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining VMStatuses in Subscription: $($Subscription.Name)"
        $VMObjects = Join-Object -Left $VMObjects -Right $VMStatuses -LeftJoinProperty ResourceId -RightJoinProperty Id -Type AllInLeft -RightProperties PowerState, StatusCode, MaintenanceRedeployStatus

        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining VMSizes in Subscription: $($Subscription.Name)"
        $VMObjects = Join-Object -Left $VMObjects -Right $VMSizes -LeftJoinProperty VMSize -RightJoinProperty Name -Type AllInLeft -RightProperties NumberOfCores, MemoryInMB, MaxDataDiskCount

        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining ReservedVMInstances in Subscription: $($Subscription.Name)"
        $VMObjects = Join-Object -Left $VMObjects -Right $ReservedVMInstances -LeftJoinProperty VMSize -RightJoinProperty VMSize -Type AllInLeft -RightProperties ReservedInstanceFamily, ReservedInstanceRatio

        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining VMRestProperties in Subscription: $($Subscription.Name)"
        $VMObjects = Join-Object -Left $VMObjects -Right $VMRestProperties -LeftJoinProperty ResourceId -RightJoinProperty id -Type AllInLeft -RightProperties createdTime, changedTime

        if ($SQLVMObjects)
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining SQLVMObjects in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $SQLVMObjects -LeftJoinProperty VMName -RightJoinProperty VMName -Type AllInLeft -RightProperties SqlServerLicenseType, SqlManagement
        }

        if ($NetworkInterfaces)
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining NetworkInterfaces0 in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $NetworkInterfaces -LeftJoinProperty NetworkInterface0 -RightJoinProperty NetworkInterface -Type AllInLeft -RightProperties @{Name = "NetworkInterface0EnableAcceleratedNetworking"; Expression = { $_.NetworkInterfaceEnableAcceleratedNetworking } }, @{Name = "NetworkInterface0Primary"; Expression = { $_.NetworkInterfacePrimary } }
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining NetworkInterfaces1 in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $NetworkInterfaces -LeftJoinProperty NetworkInterface1 -RightJoinProperty NetworkInterface -Type AllInLeft -RightProperties @{Name = "NetworkInterface1EnableAcceleratedNetworking"; Expression = { $_.NetworkInterfaceEnableAcceleratedNetworking } }, @{Name = "NetworkInterface1Primary"; Expression = { $_.NetworkInterfacePrimary } }
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining NetworkInterfaces2 in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $NetworkInterfaces -LeftJoinProperty NetworkInterface2 -RightJoinProperty NetworkInterface -Type AllInLeft -RightProperties @{Name = "NetworkInterface2EnableAcceleratedNetworking"; Expression = { $_.NetworkInterfaceEnableAcceleratedNetworking } }, @{Name = "NetworkInterface2Primary"; Expression = { $_.NetworkInterfacePrimary } }
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining NetworkInterfaces3 in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $NetworkInterfaces -LeftJoinProperty NetworkInterface3 -RightJoinProperty NetworkInterface -Type AllInLeft -RightProperties @{Name = "NetworkInterface3EnableAcceleratedNetworking"; Expression = { $_.NetworkInterfaceEnableAcceleratedNetworking } }, @{Name = "NetworkInterface3Primary"; Expression = { $_.NetworkInterfacePrimary } }
        }

        if ($VMMonitoringExtensions)
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining VMMonitoringExtensions in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $VMMonitoringExtensions -LeftJoinProperty VMName -RightJoinProperty VMName -Type AllInLeft -RightProperties WorkspaceId, VMMonitoringExtensionVersion , VMMonitoringExtensionProvisioningState
        }

        if ($SQLServerIaaSExtensions)
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining SQLServerIaaSExtensions in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $SQLServerIaaSExtensions -LeftJoinProperty VMName -RightJoinProperty VMName -Type AllInLeft -RightProperties SQLServerIaaSExtensionVersion, SQLServerIaaSExtensionProvisioningState
        }

        if ($LogAnalyticsWorkspaces)
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Joining LogAnalyticsWorkspaces in Subscription: $($Subscription.Name)"
            $VMObjects = Join-Object -Left $VMObjects -Right $LogAnalyticsWorkspaces -LeftJoinProperty WorkspaceId -RightJoinProperty WorkspaceId -Type AllInLeft -RightProperties WorkspaceSubscriptionName, WorkspaceResourceGroupName, WorkspaceName, WorkspaceSku, WorkspaceRetentionInDays
        }

        Write-Host

        $OrderedVMObjects = $VMObjects `
        | Select-Object -Property `
        @{label = "Name"; expression = { $_.VMName } }, `
        @{label = "Resource Group"; expression = { $_.ResourceGroup } }, `
        @{label = "Subscription"; expression = { $($Subscription.name) } }, `
        @{label = "Location"; expression = { $_.VMLocation } }, `
        @{label = "Availability Set"; expression = { $_.AvailabilitySet } }, `
        @{label = "Size"; expression = { $_.VMSize } }, `
        @{label = "Processor Cores"; expression = { $_.NumberOfCores } }, `
        @{label = "Memory (GB)"; expression = { $([Math]::Round([INT]$_.MemoryInMB / 1024)) } }, `
        @{label = "OS Type"; expression = { $_.OSType } }, `
        @{label = "Windows Hybrid Benefit"; expression = { $_.WindowsHybridBenefit } }, `
        @{label = "Image Publisher"; expression = { $_.ImagePublisher } }, `
        @{label = "Image Offer"; expression = { $_.ImageOffer } }, `
        @{label = "Image Sku"; expression = { $_.ImageSku } }, `
        @{label = "Image Version"; expression = { $_.ImageVersion } }, `
        @{label = "SQL Server Licence Type"; expression = { $_.SqlServerLicenseType } }, `
        @{label = "SQL Server Management Level"; expression = { $_.SqlManagement } }, `
        @{label = "SQL Server IaaS Extension Version"; expression = { $_.SQLServerIaaSExtensionVersion } }, `
        @{label = "SQL Server IaaS Extension Provisioning State"; expression = { $_.SQLServerIaaSExtensionProvisioningState } }, `
        @{label = "OS Disk Size"; expression = { $_.OSDiskSize } }, `
        @{label = "OS Disk Caching"; expression = { $_.OSDiskCaching } }, `
        @{label = "OS Disk Type"; expression = { $_.OSDiskType } }, `
        @{label = "OS Disk Storage Type"; expression = { $_.OSDiskStorageType } }, `
        @{label = "OS Disk Storage Account"; expression = { $_.OSDiskStorageAccount } }, `
        @{label = "Data Disk Count"; expression = { $_.DataDiskCount } }, `
        @{label = "Data Disk Max Count"; expression = { $_.MaxDataDiskCount } }, `
        @{label = "Network Interface 0"; expression = { $_.NetworkInterface0 } }, `
        @{label = "Network Interface 0 Accelerated Networking"; expression = { $_.NetworkInterface0EnableAcceleratedNetworking } }, `
        @{label = "Network Interface 0 Primary"; expression = { $_.NetworkInterface0Primary } }, `
        @{label = "Network Interface 1"; expression = { $_.NetworkInterface1 } }, `
        @{label = "Network Interface 1 Accelerated Networking"; expression = { $_.NetworkInterface1EnableAcceleratedNetworking } }, `
        @{label = "Network Interface 1 Primary"; expression = { $_.NetworkInterface1Primary } }, `
        @{label = "Network Interface 2"; expression = { $_.NetworkInterface2 } }, `
        @{label = "Network Interface 2 Accelerated Networking"; expression = { $_.NetworkInterface2EnableAcceleratedNetworking } }, `
        @{label = "Network Interface 2 Primary"; expression = { $_.NetworkInterface2Primary } }, `
        @{label = "Network Interface 3"; expression = { $_.NetworkInterface3 } }, `
        @{label = "Network Interface 3 Accelerated Networking"; expression = { $_.NetworkInterface3EnableAcceleratedNetworking } }, `
        @{label = "Network Interface 3 Primary"; expression = { $_.NetworkInterface3Primary } }, `
        @{label = "Boot Diagnostics Enabled"; expression = { $_.BootDiagnostcsEnabled } }, `
        @{label = "Log Analytics Subscription"; expression = { $_.WorkspaceSubscriptionName } }, `
        @{label = "Log Analytics Resource Group"; expression = { $_.WorkspaceResourceGroupName } }, `
        @{label = "Log Analytics Workspace"; expression = { $_.WorkspaceName } }, `
        @{label = "Log Analytics Workspace SKU"; expression = { $_.WorkspaceSku } }, `
        @{label = "Log Analytics Workspace Retention (Days)"; expression = { $_.WorkspaceRetentionInDays } }, `
        @{label = "VM Monitoring Extension Version"; expression = { $_.VMMonitoringExtensionVersion } }, `
        @{label = "VM Monitoring Extension Status"; expression = { $_.VMMonitoringExtensionProvisioningState } }, `
        @{label = "Reserved Instance Family"; expression = { $_.ReservedInstanceFamily } }, `
        @{label = "Reserved Instance Ratio"; expression = { $_.ReservedInstanceRatio } }, `
        @{label = "Tag (Environment)"; expression = { $_.TagEnvironment } }, `
        @{label = "Tag (Service Ticket Request ID)"; expression = { $_.TagServiceTicketRequestID } }, `
        @{label = "Tag (Service Owner)"; expression = { $_.TagServiceOwner } }, `
        @{label = "Tag (Service Name)"; expression = { $_.TagServiceName } }, `
        @{label = "Created On"; expression = { if ($_.createdTime) { $([DateTime]::Parse($_.createdTime)).ToUniversalTime() } } }, `
        @{label = "Modified On"; expression = { if ($_.changedTime) { $([DateTime]::Parse($_.createdTime)).ToUniversalTime() } } }, `
        @{label = "Power State"; expression = { $_.PowerState } }, `
        @{label = "Provisioning State"; expression = { $_.ProvisioningState } }, `
        @{label = "Status Code"; expression = { $_.StatusCode } }, `
        @{label = "Maintenance - Self Service Window"; expression = { if ($_.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) { $($_.MaintenanceRedeployStatus.PreMaintenanceWindowStartTime).ToUniversalTime().ToString() + " - " + $($_.MaintenanceRedeployStatus.PreMaintenanceWindowEndTime).ToUniversalTime().ToString() + " UTC" } } }, `
        @{label = "Maintenance - Scheduled Window"; expression = { if ($_.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) { $($_.MaintenanceRedeployStatus.MaintenanceWindowStartTime).ToUniversalTime().ToString() + " - " + $($_.MaintenanceRedeployStatus.MaintenanceWindowEndTime).ToUniversalTime().ToString() + " UTC" } } }

        # Output to a CSV file on the user's Desktop
        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Appending details of ARM Virtual Machines to file."
        $FilePath = "$env:HOMEDRIVE$env:HOMEPATH\Desktop\Azure VM Status $($DateTime).csv"
        if ($OrderedVMObjects)
        {
            $OrderedVMObjects | Export-Csv -Path $FilePath -Append -NoTypeInformation
        }
        Write-Host
    }
}

Write-Host
