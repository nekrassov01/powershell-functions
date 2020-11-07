Function Rollback-ItemCreationTime
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

<#

### Examples ###

$Directories = @(
    "C:\Work\test-1"
    "C:\Work\test-2"
)

# Example 1
Rollback-ItemCreationTime -Path $Directories -RollbackDay 365

# Example 2
Rollback-ItemCreationTime -Path $Directories -RollbackDay 365 -Recurse

# Example 3
$Directories | Rollback-ItemCreationTime -RollbackDay 90

# Example 4
$Directories | Rollback-ItemCreationTime -RollbackDay 90 -Recurse

#>