Function Encode-PSFile
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
        [string[]]$Path,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Destination = $PSScriptRoot

    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Path | ForEach-Object -Process {

            $FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($_)
            $DestinationFilePath = ${Destination} + "\" + ${FileNameWithoutExtension} + ".bat"

            $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Result"
            $Obj."FullName" = $DestinationFilePath

            $Encode = [System.Text.Encoding]::GetEncoding("utf-16")
            $Output += "@echo off"
            $Output += "`r`n"
            $Output += "PowerShell -NoProfile -ExecutionPolicy Unrestricted -EncodedCommand "
            $Output += [System.Convert]::ToBase64String($Encode.GetBytes([System.IO.File]::ReadAllText($_)))
            $Output | Out-File -FilePath $DestinationFilePath -Encoding Default

            If($?)
            {
                $Obj."Result" = "Success"
            }
            Else
            {
                $Obj."Result" = "Error"
            }

            $Output = $null
            $Result += $Obj
        }
    }

    End
    {
        return $Result
    }
}

<#

### Examples ###

$Path = @(
    "C:\test\test-01.ps1"
    "C:\test\test-02.ps1"
)

# Example 1
Encode-PSFile -Path $Path

# Example 2
Encode-PSFile -Path $Path -Destination "D:\output"

# Example 3
$Path | Encode-PSFile

# Example 4
$Path | Encode-PSFile -Destination "D:\output"

#>