<#

.Synopsis
Batch Replace Filename String

.DESCRIPTION
Batch Replace Filename String

.EXAMPLE
Rename-Bulk -Path "C:\Work\test-1","C:\Work\test-2" -TargetString "_" -NewString "-"

.EXAMPLE
"C:\Work\test-1","C:\Work\test-2" | Rename-Bulk  -TargetString "_" -NewString "-"

.NOTES
Author: nekrassov01

#>

Function Rename-Bulk
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
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$TargetString,

        [Parameter(
            Mandatory = $true
        )]
        [AllowEmptyString()]
        [string]$NewString
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Path | ForEach-Object -Process {

            $ParentDir = $_

            Get-ChildItem -Path $_ | ForEach-Object -Process {

                $NewName = Join-Path -Path $ParentDir -ChildPath $_.Name.Replace($TargetString, $NewString)

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "Name", "NewName", "Result"
                $Obj."Name" = $_.FullName
                
                $Check = $_.FullName -eq $NewName -or $null -eq $NewString

                If( -not $Check)
                {
                    Rename-Item -Path $_.FullName -NewName $NewName -Force
                }

                If($?)
                {
                    If($Check)
                    {
                        $Obj."NewName" = $_.FullName
                        $Obj."Result" = "Skip"
                    }
                    Else
                    {
                        $Obj."NewName" = $NewName
                        $Obj."Result" = "Success"
                    }
                }
                Else
                {
                    $Obj."NewName" = $_.FullName
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
