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
        [string[]]$TargetPSFilePath,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationDirectory = $PSScriptRoot

    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        Foreach($Target In $TargetPSFilePath)
        {
            $FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($Target)
            $DestinationFilePath = ${DestinationDirectory} + "\" + ${FileNameWithoutExtension} + ".bat"
            $Encode = [System.Text.Encoding]::GetEncoding("utf-16")
            $Output += "@echo off"
            $Output += "`r`n"
            $Output += "PowerShell -NoProfile -ExecutionPolicy Unrestricted -EncodedCommand "
            $Output += [System.Convert]::ToBase64String($Encode.GetBytes([System.IO.File]::ReadAllText($Target)))
            $Output | Out-File -FilePath $DestinationFilePath -Encoding Default
            $Output = $null
            $Result += $DestinationFilePath
        }
    }

    End
    {
        return $Result
    }
}

<#

### Examples ###

$TargetPSFilePath = @(
    "C:\test\test-01.ps1"
    "C:\test\test-02.ps1"
)

# Example 1
Encode-PSFile -TargetPSFilePath $TargetPSFilePath

# Example 2
Encode-PSFile -TargetPSFilePath $TargetPSFilePath -DestinationDirectory "D:\output"

# Example 3
$TargetPSFilePath | Encode-PSFile

# Example 4
$TargetPSFilePath | Encode-PSFile -DestinationDirectory "D:\output"

#>