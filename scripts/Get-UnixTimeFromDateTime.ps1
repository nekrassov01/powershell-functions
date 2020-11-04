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

<#

### Example ###

$TargetDate = @(
    "2020/10/01 0:0:0"
    "2020/11/01 0:0:0"
)

# Example 1
Get-UnixTimeFromDateTime -TargetDate $TargetDate

# Example 2
$TargetDate | Get-UnixTimeFromDateTime

#>