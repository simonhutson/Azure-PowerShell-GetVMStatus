# Azure-PowerShell-GetVMStatus

Make sure you have the correct version of PowerShell 5.x installed, by running this command:

```powershell
$PSVersionTable.PSVersion
```

If the AZ PowerShell module is not installed, then you can run these PowerShell commands in an eleveated shell:

```markdown
Find-PackageProvider -Name "Nuget" -Force -Verbose | Install-PackageProvider -Scope "CurrentUser" -Force -Confirm -Verbose
Install-Module –Name "PowerShellGet" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck –Force -Confirm -AllowClobber -Verbose
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -PackageManagementProvider "Nuget" -Verbose
Install-Module -Name "Az" -Repository "PSGallery" -Scope "CurrentUser" -AcceptLicense -SkipPublisherCheck -Force -Confirm -AllowClobber -Verbose
Set-ExecutionPolicy -Scope "CurrentUser" -ExecutionPolicy "Bypass" -ErrorAction SilentlyContinue -Confirm -Force -Verbose
```
    
- [Find-PackageProvider](https://docs.microsoft.com/powershell/module/packagemanagement/find-packageprovider) returns a list of Package Management package providers available for installation.
- [Install-PackageProvider](https://docs.microsoft.com/powershell/module/packagemanagement/install-packageprovider) Installs one or more Package Management package providers.
- [PowerShellGet](https://docs.microsoft.com/powershell/module/powershellget) is a module with commands for discovering, installing, updating and publishing PowerShell artifacts like Modules, DSC Resources, Role Capabilities, and Scripts.
- [Set-PSRepository](https://docs.microsoft.com/powershell/module/powershellget/set-psrepository) sets values for a registered repository.
- [Set-ExecutionPolicy](https://docs.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy) sets the PowerShell execution policies for Windows computers.
