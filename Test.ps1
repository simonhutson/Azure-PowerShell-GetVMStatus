Search-AzGraph -Subscription "99f4d63e-f528-428c-a810-441b61710597" -First 5000 -Query "
Resources
| where type =~ 'microsoft.compute/virtualmachines'
| extend ResourceId = id
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
| order by id asc
| project ResourceId,ResourceGroup,VMName,VMLocation,AvailabilitySet,VMSize,ProvisioningState,OSDiskType,OSDiskStorageAccount,OSDiskSize,OSDiskCaching,OSDiskStorageType,DataDiskCount,OSType,WindowsHybridBenefit,OSDiskCreateOption,ImagePublisher,ImageOffer,ImageSku,ImageVersion,NetworkInterface0,NetworkInterface1,NetworkInterface2,NetworkInterface3,BootDiagnostcsEnabled,BootDiagnostcsStorageAccount,TagEnvironment,TagServiceTicketRequestID,TagServiceOwner,TagServiceName
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.sqlvirtualmachine/sqlvirtualmachines'
    | extend ResourceId = id
    | extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
    | extend VMName = toupper(tostring(split(id,'/',8)[0]))
    | extend SqlServerLicenseType = tostring(properties.sqlServerLicenseType)
    | extend SqlManagement = tostring(properties.sqlManagement)
    | extend SqlImageOffer = tostring(properties.sqlImageOffer)
    | extend SqlImageSku = tostring(properties.sqlImageSku)
    | project ResourceId, ResourceGroup, VMName, location, SqlServerLicenseType, SqlManagement, SqlImageOffer, SqlImageSku)
on VMName
| project-away VMName1
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.compute/virtualmachines/extensions'
    | extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
    | extend VMName = toupper(tostring(split(id,'/',8)[0]))
    | extend VMMonitoringExtensionPublisher = tostring(properties.publisher)
    | extend VMMonitoringExtensionType = tostring(properties.type)
    | extend VMMonitoringExtensionVersion = tostring(properties.typeHandlerVersion)
    | extend VMMonitoringExtensionProvisioningState = tostring(properties.provisioningState)
    | extend WorkspaceId = tostring(properties.settings.workspaceId)
    | where VMMonitoringExtensionPublisher =~ 'Microsoft.EnterpriseCloud.Monitoring'
    | project ResourceGroup, VMName, VMMonitoringExtensionPublisher, VMMonitoringExtensionType, VMMonitoringExtensionVersion, VMMonitoringExtensionProvisioningState, WorkspaceId)
on VMName
| project-away VMName1
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.network/networkinterfaces'
    | extend NetworkInterface = toupper(name)
    | extend NetworkInterfaceEnableAcceleratedNetworking = tolower(properties.enableAcceleratedNetworking)
    | extend NetworkInterfacePrimary = tolower(iif(isnotnull(properties.primary),properties.primary,false))
    | extend NetworkInterfacePrivateIpAddress0 = tostring(properties.ipConfigurations[0].properties.privateIPAddress)
    | extend NetworkInterfacePrivateIpAddress1 = tostring(properties.ipConfigurations[1].properties.privateIPAddress)
    | extend NetworkInterfacePrivateIpAddress2 = tostring(properties.ipConfigurations[2].properties.privateIPAddress)
    | extend NetworkInterfacePrivateIpAddress3 = tostring(properties.ipConfigurations[3].properties.privateIPAddress)
    | project NetworkInterface0 = NetworkInterface, NetworkInterface0EnableAcceleratedNetworking = NetworkInterfaceEnableAcceleratedNetworking, NetworkInterface0Primary = NetworkInterfacePrimary, NetworkInterface0PrivateIpAddress0 = NetworkInterfacePrivateIpAddress0, NetworkInterface0PrivateIpAddress1 = NetworkInterfacePrivateIpAddress1, NetworkInterface0PrivateIpAddress2 = NetworkInterfacePrivateIpAddress2, NetworkInterface0PrivateIpAddress3 = NetworkInterfacePrivateIpAddress3)
on NetworkInterface0
| project-away NetworkInterface01
"
-Include DisplayNames


Search-AzGraph -Subscription "99f4d63e-f528-428c-a810-441b61710597" -First 5000 -Query "limit 1" -Include DisplayNames

Search-AzGraph -Subscription "99f4d63e-f528-428c-a810-441b61710597" -First 5000 -Query "
Resources
| extend ResourceId = id
| extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
| extend VMName = toupper(tostring(split(id,'/',8)[0]))
| extend SqlServerLicenseType = tostring(properties.sqlServerLicenseType)
| extend SqlManagement = tostring(properties.sqlManagement)
| extend SqlImageOffer = tostring(properties.sqlImageOffer)
| extend SqlImageSku = tostring(properties.sqlImageSku)
| where type =~ 'microsoft.sqlvirtualmachine/sqlvirtualmachines'
| project ResourceId, ResourceGroup, VMName, location, SqlServerLicenseType, SqlManagement, SqlImageOffer, SqlImageSku
"
-Include DisplayNames

Search-AzGraph -Subscription "99f4d63e-f528-428c-a810-441b61710597" -First 5000 -Query "
Resources
| where type =~ 'microsoft.compute/virtualmachines/extensions'
| extend ResourceGroup = toupper(tostring(split(id,'/',4)[0]))
| extend VMName = toupper(tostring(split(id,'/',8)[0]))
| extend VMMonitoringExtensionPublisher = tostring(properties.publisher)
| extend VMMonitoringExtensionType = tostring(properties.type)
| extend VMMonitoringExtensionVersion = tostring(properties.typeHandlerVersion)
| extend VMMonitoringExtensionProvisioningState = tostring(properties.provisioningState)
| extend WorkspaceId = tostring(properties.settings.workspaceId)
| where VMMonitoringExtensionPublisher =~ 'Microsoft.EnterpriseCloud.Monitoring'
| project ResourceGroup, VMName, VMMonitoringExtensionPublisher, VMMonitoringExtensionType, VMMonitoringExtensionVersion, VMMonitoringExtensionProvisioningState, WorkspaceId
"

Search-AzGraph -Subscription "99f4d63e-f528-428c-a810-441b61710597" -First 5000 -Query "
Resources
| where type =~ 'microsoft.network/networkinterfaces'
| extend NetworkInterface = toupper(name)
| extend NetworkInterfaceEnableAcceleratedNetworking = tolower(properties.enableAcceleratedNetworking)
| extend NetworkInterfacePrimary = tolower(iif(isnotnull(properties.primary),properties.primary,false))
| extend NetworkInterfacePrivateIpAddress0 = tostring(properties.ipConfigurations[0].properties.privateIPAddress)
| extend NetworkInterfacePrivateIpAddress1 = tostring(properties.ipConfigurations[1].properties.privateIPAddress)
| extend NetworkInterfacePrivateIpAddress2 = tostring(properties.ipConfigurations[2].properties.privateIPAddress)
| extend NetworkInterfacePrivateIpAddress3 = tostring(properties.ipConfigurations[3].properties.privateIPAddress)
| project NetworkInterface, NetworkInterfaceEnableAcceleratedNetworking, NetworkInterfacePrimary, NetworkInterfacePrivateIpAddress0, NetworkInterfacePrivateIpAddress1, NetworkInterfacePrivateIpAddress2, NetworkInterfacePrivateIpAddress3
"
<#

.SYNOPSIS
Retrieve the status of all Azure Virtual Machines across all Subscriptions associated with a specific Azure AD Tenant

.NOTES
Make sure you have the correct versions of PowerShell 5.x installed, by running this command:

    $PSVersionTable.PSVersion

If the AZ PowerShell module is not installed, then you can run these PowerShell commands in an eleveated shell:

    Find-PackageProvider -Name "Nuget" -Force -Verbose | Install-PackageProvider -Scope "CurrentUser" -Force -Confirm -Verbose
    Install-Module -Name "PowerShellGet" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -PackageManagementProvider "Nuget" -Verbose
    Install-Module -Name "Az" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    Set-ExecutionPolicy -Scope "CurrentUser" -ExecutionPolicy "Bypass" -ErrorAction SilentlyContinue -Confirm -Force -Verbose

#>

# Import Modules
Import-Module .\Modules\Login-Azure.psm1
Import-Module .\Modules\Get-ReservedVMInstanceFamilies.ps1
Import-Module .\Modules\Join-Object.ps1

# Check PowerShell Version
$PowerShellVersion = $PSVersionTable.PSVersion
if ($PowerShellVersion.Major -lt 5)
{
    Write-Host -BackgroundColor Red -ForegroundColor White "PowerShell needs to be version 5.x."
    Exit
}

# Set Globals
$ErrorActionPreference = 'Stop'

# Call Login-Azure module
$Account = SignIn

# Get Authentication Access Token, for use with the Azure REST API
$TokenCache = (Get-AzContext).TokenCache
$Token = $TokenCache.ReadItems() | Where-Object { $_.TenantId -eq $Account.Context.Tenant.Id -and $_.DisplayableId -eq $Account.Context.Account.Id -and $_.Resource -eq "https://management.core.windows.net/" }
$AccessToken = "Bearer " + $Token.AccessToken

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


Search-AzGraph -


Search-AzGraph -Subscription $Subscription.Id -First 5000 -Include DisplayNames -Query "
    Resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | extend ResourceId = id
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
    | project ResourceId,ResourceGroup,VMName,VMLocation,AvailabilitySet,VMSize,ProvisioningState,OSDiskType,OSDiskStorageAccount,OSDiskSize,OSDiskCaching,OSDiskStorageType,DataDiskCount,OSType,WindowsHybridBenefit,OSDiskCreateOption,ImagePublisher,ImageOffer,ImageSku,ImageVersion,NetworkInterface0,NetworkInterface1,NetworkInterface2,NetworkInterface3
    "

| extend BootDiagnostcsStorageAccount = toupper(split(split(split(properties.diagnosticsProfile.bootDiagnostics.storageUri, '//', 1)[0], '/', 0)[0], '.', 0)[0])
| extend BootDiagnostcsEnabled = iif(isnotnull(properties.diagnosticsProfile.bootDiagnostics), properties.diagnosticsProfile.bootDiagnostics.enabled, 'False')
| extend TagEnvironment = tostring(tags.Environment)
| extend TagServiceTicketRequestID = tostring(tags.['Service Ticket Request ID'])
| extend TagServiceOwner = tostring(tags.['Service Owner'])
| extend TagServiceName = tostring(tags.['Service Name'])
| where type =~ 'microsoft.compute/virtualmachines'
| order by id asc
| project ResourceId, ResourceGroup, VMName, VMLocation, AvailabilitySet, VMSize, ProvisioningState, OSDiskType, OSDiskStorageAccount, OSDiskSize, OSDiskCaching, OSDiskStorageType, DataDiskCount, OSType, WindowsHybridBenefit, OSDiskCreateOption, ImagePublisher, ImageOffer, ImageSku, ImageVersion, NetworkInterface0, NetworkInterface1, NetworkInterface2, NetworkInterface3, BootDiagnostcsEnabled, BootDiagnostcsStorageAccount, TagEnvironment, TagServiceTicketRequestID, TagServiceOwner, TagServiceName


Search-AzGraph -Subscription $Subscription.Id -First 5000 -Query "
    Resources
| where type =~ 'microsoft.compute/virtualmachines'
| extend nics=array_length(properties.networkProfile.networkInterfaces)
| mv-expand nic=properties.networkProfile.networkInterfaces
| where nics == 1 or nic.properties.primary =~ 'true' or isempty(nic)
| project vmId = id, vmName = name, vmSize=tostring(properties.hardwareProfile.vmSize), nicId = tostring(nic.id)
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.network/networkinterfaces'
    | extend ipConfigsCount=array_length(properties.ipConfigurations)
    | mv-expand ipconfig=properties.ipConfigurations
    | where ipConfigsCount == 1 or ipconfig.properties.primary =~ 'true'
    | project nicId = id, publicIpId = tostring(ipconfig.properties.publicIPAddress.id))
on nicId
| project-away nicId1
| summarize by vmId, vmName, vmSize, nicId, publicIpId
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.network/publicipaddresses'
    | project publicIpId = id, publicIpAddress = properties.ipAddress)
on publicIpId
| project-away publicIpId1"
