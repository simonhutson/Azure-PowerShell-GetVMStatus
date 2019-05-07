## Azure-PowerShell-GetVMStatus

Make sure you have the correct version of PowerShell 5.x installed, by running this command:

    $PSVersionTable.PSVersion

If the AZ PowerShell module is not installed, then you can run these PowerShell commands in an eleveated shell:

### Install latest Nuget package management provider
    [Find-PackageProvider](https://docs.microsoft.com/powershell/module/packagemanagement/find-packageprovider) returns a list of Package Management package providers available for installation.
    [Install-PackageProvider](https://docs.microsoft.com/powershell/module/packagemanagement/install-packageprovider) Installs one or more Package Management package providers.
    Find-PackageProvider -Name "Nuget" -Force -Verbose | Install-PackageProvider -Scope "CurrentUser" -Force -Confirm -Verbose
    
### Install latest PowerShellGet module
    The PowerShellGet module contains cmdlets for discovering, installing, updating and publishing PowerShell packages
    [PowerShellGet](https://docs.microsoft.com/powershell/module/powershellget) is a module with commands for discovering, installing, updating and publishing PowerShell artifacts like Modules, DSC Resources, Role Capabilities, and Scripts.
    Install-Module –Name "PowerShellGet" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck –Force -Confirm -AllowClobber -Verbose
    
    # The Microsoft PowerShell Gallery is the central repository for Windows PowerShell content
    # https://docs.microsoft.com/powershell/gallery/overview
    # https://www.powershellgallery.com
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -PackageManagementProvider "Nuget" -Verbose
    
    # Install Az modules
    Install-Module -Name "Az" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
    
    # Set Execution Policy
    # https://docs.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy
    Set-ExecutionPolicy -Scope "CurrentUser" -ExecutionPolicy "Bypass" -ErrorAction SilentlyContinue -Confirm -Force -Verbose
