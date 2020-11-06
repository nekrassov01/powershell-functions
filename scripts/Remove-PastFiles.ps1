Function Remove-PastFiles
{
    [OutputType([System.Object])]
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [int]$Day,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [switch]$Recurse
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Path | ForEach-Object -Process {

            If($Recurse)
            {
                $Target = Get-ChildItem -Path $_ -Recurse
            }
            Else
            {
                $Target = Get-ChildItem -Path $_
            }

            $Target | Where-Object -FilterScript { $_.CreationTime -lt (Get-Date).AddDays(-$Day) } | ForEach-Object -Process {

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Result"
                $Obj."FullName" = $_.FullName

                $_ | Remove-Item -Force #-WhatIf

                If($?)
                {
                    $Obj."Result" = "Success"
                }
                Else
                {
                    $Obj."Result" = "Error"
                }

                $Result += $Obj
            }         
        }
    }

    End
    {
        return $Result
    }
}

<#

### Examples ###

$Directories = @(
    "C:\Work\link-1"
    "C:\Work\link-2"
)

# Example 1
Remove-PastFiles -Path $Directories -Day 90

# Example 2
$Directories | Remove-PastFiles -Day 90

#>