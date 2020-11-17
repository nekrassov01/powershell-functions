<#

.Synopsis
Delete Old Folders and Files

.DESCRIPTION
Delete Old Folders and Files:
 - Select Property "CreationTime" or "LastWriteTime"

.EXAMPLE
Remove-PastItem -Path "C:\Work\test-1", "C:\Work\test-2" -Day 90

.EXAMPLE
"C:\Work\test-1", "C:\Work\test-2" | Remove-PastItem -Day 90

.EXAMPLE
Remove-PastItem -Path "C:\Work\test-1", "C:\Work\test-2" -Day 90 -Property CreationTime

.EXAMPLE
"C:\Work\test-1", "C:\Work\test-2" | Remove-PastItem -Day 90 -Property CreationTime

.EXAMPLE
Remove-PastItem -Path "C:\Work\test-1", "C:\Work\test-2" -Day 90 -Property LastWriteTime

.EXAMPLE
"C:\Work\test-1", "C:\Work\test-2" | Remove-PastItem -Day 90 -Property LastWriteTime

.NOTES
Author: nekrassov01

#>

Function Remove-PastItem
{
    [OutputType([System.Object])]
    [CmdletBinding(SupportsShouldProcess)]
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
                $Target = $Target | Where-Object -FilterScript { $_.LastWriteTime -le (Get-Date).AddDays(-$Day) }
            }
            Else
            {
                $Target = $Target | Where-Object -FilterScript { $_.CreationTime -le (Get-Date).AddDays(-$Day) }
            }

            $Target | ForEach-Object -Process {

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Property", "Result"
                $Obj."FullName" = $_.FullName
                $Obj."Property" = $Property

                $_ | Remove-Item -Force -Recurse

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
