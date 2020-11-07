Function Rename-Bulk
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
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$TargetString,

        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
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
                $Obj."NewName" = $NewName

                $Check = $_.FullName -eq $NewName

                If( -not $Check)
                {
                    Rename-Item -Path $_.FullName -NewName $NewName -Force
                }

                If($?)
                {
                    If($Check)
                    {
                        $Obj."Result" = "Skip"
                    }
                    Else
                    {
                        $Obj."Result" = "Success"
                    }
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

### Example ###

$Directories = @(
    "C:\Work\test-1"
    "C:\Work\test-2"
)

# Example 1
Rename-Bulk -Path $Directories -TargetString "_" -NewString "-"

# Example 2
$Directories | Rename-Bulk  -TargetString "_" -NewString "-"

#>