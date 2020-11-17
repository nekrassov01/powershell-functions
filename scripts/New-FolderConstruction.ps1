### Requires -Version 5.1 ###

<#
.Synopsis
Build Directory structure

.DESCRIPTION
Build Directory structure

.EXAMPLE
New-FolderConstruction -Path "folder-1", "folder-2" -Root "C:\Work"

.EXAMPLE
"folder-1", "folder-2" | New-FolderConstruction -Root "C:\Work"

.NOTES
Author: nekrassov01
#>

Function New-FolderConstruction
{
    [OutputType([System.IO.FileInfo])]
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
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Root = $PSScriptRoot
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Path | ForEach-Object -Process {

            $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Result"

            $Target = Join-Path -Path $Root -ChildPath $_
            $Obj."FullName" = $Target
            New-Item -Path $Target -ItemType Directory -Force | Out-Null

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

    End
    {
        return $Result
    }
}
