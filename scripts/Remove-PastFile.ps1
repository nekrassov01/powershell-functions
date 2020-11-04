Function Remove-PastFile
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

            $Target | Where-Object -FilterScript { $_.CreationTime -lt (Get-Date).AddDays(-$Days) } | ForEach-Object -Process {

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

### Examples ###

# Example 1
Remove-PastFile -Path "C:\Work\link-1", "C:\Work\link-2" -Day 90

# Example 2
"C:\Work\link-1", "C:\Work\link-2" | Remove-PastFile -Day 90