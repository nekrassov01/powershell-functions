### Requires -Version 5.1 ###

<#
.Synopsis
Display DateTime on the Console Output

.DESCRIPTION
Display DateTime on the Console Output

.EXAMPLE
Out-Log -String "test"

.EXAMPLE
Out-Log "test"

.NOTES
Author: nekrassov01
#>

Function Out-Log
{
    [OutputType([System.String])]
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$String
    )

    Process
    {
        $LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[${LogTime}] ${String}"
    }

    End
    {
        Clear-Item -Path Variable:LogTime
        Clear-Item -Path Variable:String
    }
}
