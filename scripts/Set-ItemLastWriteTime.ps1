Function Set-ItemLastWriteTime
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
        [string]$DateTime,

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

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "FullName", "Result"
                $Obj."FullName" = $_.FullName

                $_ | Set-ItemProperty -Name LastWriteTime -Value $DateTime
            
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

# Example 1
Set-ItemLastWriteTime -Path "C:\test\folder-1", "C:\test\folder-2" -Day 365

# Example 2
Set-ItemLastWriteTime -Path "C:\test\folder-1", "C:\test\folder-2" -Day 365 -Recurse

# Example 3
"C:\test\folder-1", "C:\test\folder-2" | Set-ItemLastWriteTime -Day 90
 
# Example 4
"C:\test\folder-1", "C:\test\folder-2" | Set-ItemLastWriteTime -Day 90 -Recurse

#>