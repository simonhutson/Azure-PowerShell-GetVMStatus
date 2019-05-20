function Get-ChildObject
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
        $ReturnValue = ""
        if ($Object -and $Path)
        {
            $EvaluationExpression = '$Object'

            foreach ($Token in $Path.Split("."))
            {
                If ($Token)
                {
                    $EvaluationExpression += '.' + $Token
                    if ($null -ne (Invoke-Expression $EvaluationExpression))
                    {
                        $ReturnValue = Invoke-Expression $EvaluationExpression
                    }
                    else
                    {
                        $ReturnValue = ""
                    }
                }
            }
        }
        Write-Output -InputObject $ReturnValue
    }
    End
    {
    }
}