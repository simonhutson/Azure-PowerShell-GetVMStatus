function Get-ClassicVMSizes
{

    <#

    .SYNOPSIS
    Create a PowerShell object to contain the Azure Classic VM sizes

    #>

    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        $ClassicVMSizes = @()

        $ExtraSmall = ($VMSizes | Where-Object { $_.Name -eq "Basic_A0" } | Get-Unique).PSObject.Copy()
        $ExtraSmall.Name = "ExtraSmall"
        $ClassicVMSizes += $ExtraSmall

        $Small = ($VMSizes | Where-Object { $_.Name -eq "Basic_A1" } | Get-Unique).PSObject.Copy()
        $Small.Name = "Small"
        $ClassicVMSizes += $Small

        $Medium = ($VMSizes | Where-Object { $_.Name -eq "Basic_A2" } | Get-Unique).PSObject.Copy()
        $Medium.Name = "Medium"
        $ClassicVMSizes += $Medium

        $Large = ($VMSizes | Where-Object { $_.Name -eq "Basic_A3" } | Get-Unique).PSObject.Copy()
        $Large.Name = "Large"
        $ClassicVMSizes += $Large

        $ExtraLarge = ($VMSizes | Where-Object { $_.Name -eq "Basic_A4" } | Get-Unique).PSObject.Copy()
        $ExtraLarge.Name = "ExtraLarge"
        $ClassicVMSizes += $ExtraLarge

        $A5 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A5" } | Get-Unique).PSObject.Copy()
        $A5.Name = "A5"
        $ClassicVMSizes += $A5

        $A6 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A6" } | Get-Unique).PSObject.Copy()
        $A6.Name = "A6"
        $ClassicVMSizes += $A6

        $A7 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A7" } | Get-Unique).PSObject.Copy()
        $A7.Name = "A7"
        $ClassicVMSizes += $A7

        $A8 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A8" } | Get-Unique).PSObject.Copy()
        $A8.Name = "A8"
        $ClassicVMSizes += $A8

        $A9 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A9" } | Get-Unique).PSObject.Copy()
        $A9.Name = "A9"
        $ClassicVMSizes += $A9

        $A10 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A10" } | Get-Unique).PSObject.Copy()
        $A10.Name = "A10"
        $ClassicVMSizes += $A10

        $A11 = ($VMSizes | Where-Object { $_.Name -eq "Standard_A11" } | Get-Unique).PSObject.Copy()
        $A11.Name = "A11"
        $ClassicVMSizes += $A11
    }
    Process
    {
        Write-Output -InputObject $ClassicVMSizes
    }
    End
    {
    }
}