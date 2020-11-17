<#

.Synopsis
Convert DateTime to UnixTime

.DESCRIPTION
Convert DateTime to UnixTime

.EXAMPLE
Get-UnixTimeFromDateTime -TargetTime "2020/10/01 0:0:0", "2020/11/01 0:0:0"

.EXAMPLE
"2020/10/01 0:0:0", "2020/11/01 0:0:0" | Get-UnixTimeFromDateTime

.NOTES
Author: nekrassov01

#>

Function Get-UnixTimeFromDateTime
{
    [OutputType([System.Double])]
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$True
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$TargetDate
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
        $BaseTime = Get-Date -Date "1970/1/1 0:0:0 GMT"
    }

    Process
    {
        $TargetDate | ForEach-Object -Process {
            $Result += ((Get-Date -Date $_) - $BaseTime).TotalSeconds
        }
    }

    End
    {
        return $Result
    }
}
