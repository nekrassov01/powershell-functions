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
        [ValidateSet(
            "CreationTime",
            "LastWriteTime"
        )]
        [string]$Property = "CreationTime"
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Path | ForEach-Object -Process {

            $Target = Get-ChildItem -Path $_ -Recurse            

            If($Property -eq "LastWriteTime")
            {
                $Target = $Target | Where-Object -FilterScript { $_.LastWriteTime -lt (Get-Date).AddDays(-$Day) }
            }
            Else
            {
                $Target = $Target | Where-Object -FilterScript { $_.CreationTime -lt (Get-Date).AddDays(-$Day) }
            }

            $Target | ForEach-Object -Process {

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Property", "Result"
                $Obj."FullName" = $_.FullName
                $Obj."Property" = $Property

                $_ | Remove-Item -Force -Recurse #-WhatIf

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

# Example 3
Remove-PastFiles -Path $Directories -Day 90 -Property CreationTime

# Example 4
$Directories | Remove-PastFiles -Day 90 -Property CreationTime

# Example 5
Remove-PastFiles -Path $Directories -Day 90 -Property LastWriteTime

# Example 6
$Directories | Remove-PastFiles -Day 90 -Property LastWriteTime

#>