### Requires -Version 5.1 ###

<#
.Synopsis
Rollback the CreationTime of Folders and Files

.DESCRIPTION
Rollback the CreationTime of Folders and Files

.EXAMPLE
Reset-ItemCreationTime -Path "C:\test\test-01.ps1", "C:\test\test-02.ps1" -RollbackDay 365

.EXAMPLE
Reset-ItemCreationTime -Path "C:\test\test-01.ps1", "C:\test\test-02.ps1" -RollbackDay 365 -Recurse

.EXAMPLE
"C:\test\test-01.ps1", "C:\test\test-02.ps1" | Reset-ItemCreationTime -RollbackDay 365

.EXAMPLE
"C:\test\test-01.ps1", "C:\test\test-02.ps1" | Reset-ItemCreationTime -RollbackDay 365 -Recurse

.NOTES
Author: nekrassov01
#>

Function Reset-ItemCreationTime
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
        [string]$RollBackDay,

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

            $Target | ForEach-Object -Process {

                $AfterRollback = $_.CreationTime.AddDays(-$RollbackDay)

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Property", "BeforeRollback", "AfterRollback", "Result"
                $Obj."FullName" = $_.FullName
                $Obj."Property" = "CreationTime"
                $Obj."BeforeRollback" = $_.CreationTime
                $Obj."AfterRollback" = $AfterRollback

                $_ | Set-ItemProperty -Name CreationTime -Value $AfterRollback
            
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
