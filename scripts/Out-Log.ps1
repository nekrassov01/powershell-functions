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

<#

### Example ###

# Example 1
Out-Log -String "test"

# Example 2
Out-Log "test"

#>