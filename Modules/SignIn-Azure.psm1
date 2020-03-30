function SignIn
{

    <#

    .SYNOPSIS
    Retrieves a child/grandchild property of a PowerShell object

    #>

    [CmdletBinding()]
    Param
    (
        [System.Object]$Object,
        [string]$Path
    )
    Begin
    {
    }
    Process
    {
        $PowerShellVersion = $PSVersionTable.PSVersion
        if ($PowerShellVersion.Major -lt 5)
        {
            Write-Host -BackgroundColor Red -ForegroundColor White "PowerShell needs to be version 5.x. or higher"
            Exit
        }

        # Login to the user's default Azure AD Tenant
        Write-Host -BackgroundColor Yellow -ForegroundColor DarkBlue "Login to User's default Azure AD Tenant"
        $Account = Connect-AzAccount
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
            $Account = Connect-AzAccount -Tenant $Tenant.Id
            Write-Host
        }

        Write-Output -InputObject $Account

    }
    End
    {
    }
}
