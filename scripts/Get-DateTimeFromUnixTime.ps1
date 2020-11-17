<#

.Synopsis
Convert UnixTime to DateTime

.DESCRIPTION
Convert UnixTime to DateTime

.EXAMPLE
Get-DateTimeFromUnixTime -TargetTime 1601478000, 1604156400

.EXAMPLE
1601478000, 1604156400 | Get-DateTimeFromUnixTime

.NOTES
Author: nekrassov01

#>

Function Get-DateTimeFromUnixTime
{
    [OutputType([System.DateTime])]
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$True
        )]
        [ValidateNotNullOrEmpty()]
        [System.Double[]]$TargetTime
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
        $BaseTime = Get-Date -Date "1970/1/1 0:0:0 GMT"
    }

    Process
    {
        $TargetTime | ForEach-Object -Process {
            $Result += $BaseTime.AddSeconds($_)
        }
    }

    End
    {
        return $Result
    }
}
