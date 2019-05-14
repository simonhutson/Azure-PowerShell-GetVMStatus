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
    Install-Module -Name "PowerShellGet" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Install-Module -Name "Az" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Install-Module -Name "Az.ResourceGraph" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose

#>

#region imports

Import-Module .\Get-ReservedVMInstances.ps1
Import-Module .\Join-Object.ps1

#endregion


$ErrorActionPreference = 'Stop'
$DateTime = Get-Date -f 'yyyy-MM-dd HHmmss'

#region Login

# Login to the user's default Azure AD Tenant
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Login to User's default Azure AD Tenant"
$Account = Login-AzAccount
Login
Write-Host

# Get the list of Azure AD Tenants this user has access to, and select the correct one
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure AD Tenants for this User"
$Tenants = @(Get-AzTenant)
Write-Host

# Get the list of Azure AD Tenants this user has access to, and select the correct one
if ($Tenants.Count -gt 1) # User has access to more than one Azure AD Tenant
{
    $Tenant = $Tenants | Out-GridView -Title "Select the Azure AD Tenant you wish to use..." -OutputMode Single
}
elseif ($Tenants.Count -eq 1) # User has access to only one Azure AD Tenant
{
    $Tenant = $Tenants.Item(0)
}
else # User has access to no Azure AD Tenant
{
    Return
}

# Check if the current Azure AD Tenant is the required Tenant
if ($Account.Context.Tenant.Id -ne $Tenant.Id)
{
    # Login to the required Azure AD Tenant
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Login to correct Azure AD Tenant"
    $Account = Add-AzAccount -TenantId $Tenant.Id
    Write-Host
}

# Get Authentication Access Token, for use with the Azure REST API
$TokenCache = (Get-AzContext).TokenCache
$Token = $TokenCache.ReadItems() | Where-Object { $_.TenantId -eq $Tenant.Id -and $_.DisplayableId -eq $Account.Context.Account.Id -and $_.Resource -eq "https://management.core.windows.net/" }
$AccessToken = "Bearer " + $Token.AccessToken


#endregion

#region Select subscription(s)

# Get list of Subscriptions associated with this Azure AD Tenant, for which this User has access
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure Subscriptions for this Azure AD Tenant"
$AllSubscriptions = @(Get-AzSubscription -TenantId $Tenant.Id)
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

#endregion

#region Get VM Sizes

$VMSizes = @()
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Azure VM Sizes across all locations"

# Get list of Azure Locations associated with this Subscription, for which this User has access and that support VMs
$Locations = Get-AzLocation | Where-Object { $_.Providers -eq "Microsoft.Compute" }

# Loop through each Azure Location to retrieve a complete list of VM Sizes
foreach ($Location in $Locations)
{
    try
    {
        $VMSizes += Get-AzVMSize -Location $($Location.Location) | Select-Object Name, NumberOfCores, MemoryInMB, MaxDataDiskCount
        Write-Host -NoNewline "."
    }
    catch
    {
        #Do Nothing
    }
}
$VMSizes = $VMSizes | Select-Object -Unique Name, NumberOfCores, MemoryInMB, MaxDataDiskCount
Write-Host

#endregion

#region Get ARM VM Details

# Get the list of all the Reserved VM Instances
Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of Reservered Virtual Machine Instances"
$ReservedVMInstances = Get-ReservedVMInstances
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

    # Get the created & last updated date/time of all the ARM VMs in the current Subscription by calling the Azure REST API
    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving created & last updated date/time of ARM Virtual Machines in Subscription: $($Subscription.Name)"
    $Headers = @{"Content-Type" = "application\json"; "Authorization" = "$AccessToken" }
    $VMRestProperties = Invoke-RestMethod -Method "Get" -Headers $Headers -Uri "https://management.azure.com/subscriptions/$($Subscription.Id)/resources?`$filter=resourcetype eq 'Microsoft.Compute/virtualMachines'&`$expand=createdTime,changedTime&api-version=2018-08-01" | Select-Object -ExpandProperty value
    Write-Host

    Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Retrieving list of ARM Virtual Machines in Subscription: $($Subscription.Name)"
    $VMObjects = Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    where type =~ 'microsoft.compute/virtualmachines'
    | order by id asc
    | project
    ResourceId = id,
    ResourceGroup = toupper(resourceGroup),
    VMName = toupper(name),
    VMLocation = location,
    AvailabilitySet = toupper(split(properties.availabilitySet.id,'/',8)[0]),
    VMSize = properties.hardwareProfile.vmSize,
    ProvisioningState = properties.provisioningState,
    OSDiskType = iif(isnotnull(properties.storageProfile.osDisk.managedDisk),'Managed','Unmanged'),
    OSDiskStorageAccount = toupper(split(split(split(properties.storageProfile.osDisk.vhd.uri,'//',1)[0],'/',0)[0],'.',0)[0]),
    OSDiskSize = properties.storageProfile.osDisk.diskSizeGB,
    OSDiskCaching = properties.storageProfile.osDisk.caching,
    OSDiskStorageType = properties.storageProfile.osDisk.managedDisk.storageAccountType,
    DataDiskCount = array_length(properties.storageProfile.dataDisks),
    OSType = properties.storageProfile.osDisk.osType,
    WindowsHybridBenefit = iif(properties.licenseType =~ 'Windows_Server','Enabled',iif(properties.storageProfile.osDisk.osType =~ 'Windows','Not Enabled','Not Supported')),
    OSDiskCreateOption = properties.storageProfile.osDisk.createOption,
    ImagePublisher = properties.storageProfile.imageReference.publisher,
    ImageOffer = properties.storageProfile.imageReference.offer,
    ImageSku = properties.storageProfile.imageReference.sku,
    ImageVersion = properties.storageProfile.imageReference.version,
    NetworkInterface0 = toupper(split(properties.networkProfile.networkInterfaces[0].id,'/',8)[0]),
    NetworkInterface1 = toupper(split(properties.networkProfile.networkInterfaces[1].id,'/',8)[0]),
    NetworkInterface2 = toupper(split(properties.networkProfile.networkInterfaces[2].id,'/',8)[0]),
    NetworkInterface3 = toupper(split(properties.networkProfile.networkInterfaces[3].id,'/',8)[0]),
    BootDiagnostcsEnabled = iif(isnotnull(properties.diagnosticsProfile.bootDiagnostics),properties.diagnosticsProfile.bootDiagnostics.enabled,'False'),
    BootDiagnostcsStorageAccount = toupper(split(split(split(properties.diagnosticsProfile.bootDiagnostics.storageUri,'//',1)[0],'/',0)[0],'.',0)[0])
    "
    Write-Host

    if ($VMObjects)
    {
        $VMObjects = Join-Object -Left $VMObjects -Right $VMStatuses -LeftJoinProperty ResourceId -RightJoinProperty Id -Type AllInLeft -RightProperties PowerState, ProvisioningState, StatusCode, MaitenanceRedeployStatus

        $VMObjects = Join-Object -Left $VMObjects -Right $VMSizes -LeftJoinProperty VMSize -RightJoinProperty Name -Type AllInLeft -RightProperties NumberOfCores, MemoryInMB, MaxDataDiskCount

        $VMObjects = Join-Object -Left $VMObjects -Right $ReservedVMInstances -LeftJoinProperty VMSize -RightJoinProperty VMSize -Type AllInLeft -RightProperties ReservedInstanceFamily, ReservedInstanceRatio

        $VMObjects = Join-Object -Left $VMObjects -Right $VMRestProperties -LeftJoinProperty ResourceId -RightJoinProperty id -Type AllInLeft -RightProperties createdTime, changedTime

        $OrderedVMObjects = $VMObjects `
        | Select-Object -Property `
        @{label = "Created On"; expression = { if ($_.createdTime) { $([DateTime]::Parse($_.createdTime)).ToUniversalTime() } } }, `
        @{label = "Modified On"; expression = { if ($_.changedTime) { $([DateTime]::Parse($_.createdTime)).ToUniversalTime() } } }, `
        @{label = "Subscription"; expression = { $($Subscription.name) } }, `
        @{label = "Resource Group"; expression = { $_.ResourceGroup } }, `
        @{label = "VM Name"; expression = { $_.VMName } }, `
        @{label = "VM Location"; expression = { $_.VMLocation } }, `
        @{label = "VM Size"; expression = { $_.VMSize } }, `
        @{label = "VM Processor Cores"; expression = { $_.NumberOfCores } }, `
        @{label = "VM Memory (GB)"; expression = { $([Math]::Round([INT]$_.MemoryInMB / 1024)) } }, `
        @{label = "VM Reserved Instance Family"; expression = { $_.ReservedInstanceFamily } }, `
        @{label = "VM Reserved Instance Ratio"; expression = { $_.ReservedInstanceRatio } }, `
        @{label = "Availability Set"; expression = { $_.AvailabilitySet } }, `
        @{label = "Power State"; expression = { $_.PowerState } }, `
        @{label = "Provisioning State"; expression = { $_.ProvisioningState } }, `
        @{label = "Status Code"; expression = { $_.StatusCode } }, `
        @{label = "Maintenance - Self Service Window"; expression = { if ($_.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) { $($_.MaintenanceRedeployStatus.PreMaintenanceWindowStartTime).ToUniversalTime().ToString() + " - " + $($_.MaintenanceRedeployStatus.PreMaintenanceWindowEndTime).ToUniversalTime().ToString() + " UTC" } } }, `
        @{label = "Maintenance - Scheduled Window"; expression = { if ($_.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) { $($_.MaintenanceRedeployStatus.MaintenanceWindowStartTime).ToUniversalTime().ToString() + " - " + $($_.MaintenanceRedeployStatus.MaintenanceWindowEndTime).ToUniversalTime().ToString() + " UTC" } } }, `
        @{label = "Boot Diagnostics Enabled"; expression = { $_.BootDiagnostcsEnabled } }, `
        @{label = "OS Type"; expression = { $_.OSType } }, `
        @{label = "Windows Hybrid Benefit"; expression = { $_.WindowsHybridBenefit } }, `
        @{label = "Image Publisher"; expression = { $_.ImagePublisher } }, `
        @{label = "Image Offer"; expression = { $_.ImageOffer } }, `
        @{label = "Image Sku"; expression = { $_.ImageSku } }, `
        @{label = "Image Version"; expression = { $_.ImageVersion } }, `
        @{label = "OS Disk Size"; expression = { $_.OSDiskSize } }, `
        @{label = "OS Disk Caching"; expression = { $_.OSDiskCaching } }, `
        @{label = "OS Disk Type"; expression = { $_.OSDiskType } }, `
        @{label = "OS Disk Storage Type"; expression = { $_.OSDiskStorageType } }, `
        @{label = "OS Disk Storage Account"; expression = { $_.OSDiskStorageAccount } }, `
        @{label = "Data Disk Count"; expression = { $_.DataDiskCount } }, `
        @{label = "Data Disk Max Count"; expression = { $_.MaxDataDiskCount } }, `
        @{label = "Network Interface 0"; expression = { $_.NetworkInterface0 } }, `
        @{label = "Network Interface 1"; expression = { $_.NetworkInterface1 } }, `
        @{label = "Network Interface 2"; expression = { $_.NetworkInterface2 } }, `
        @{label = "Network Interface 3"; expression = { $_.NetworkInterface3 } }

        # Output to a CSV file on the user's Desktop
        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Appending details of ARM Virtual Machines to file."
        $FilePath = "$env:HOMEDRIVE$env:HOMEPATH\Desktop\Azure Resource Graph VM Status $($DateTime).csv"
        if ($OrderedVMObjects)
        {
            $OrderedVMObjects | Export-Csv -Path $FilePath -Append -NoTypeInformation
        }
        Write-Host
    }
}
#endregion

Write-Host
