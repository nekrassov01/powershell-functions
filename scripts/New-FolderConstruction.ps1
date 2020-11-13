Function New-FolderConstruction
{
    [OutputType([System.IO.FileInfo])]
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

<#

### Example ###

$Directories = @(
    "folder-1"
    "folder-2"
)

# Example 1
New-FolderConstruction -Path $Directories -Root "C:\Work"

# Example 2
$Directories | New-FolderConstruction -Root "C:\Work"

#>