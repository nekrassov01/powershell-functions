Function Get-NTAccountFromSID
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
        [string[]]$Sid
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $Sid | ForEach-Object -Process {
            $Obj = [System.Security.Principal.SecurityIdentifier]$_
            $Result += $Obj.Translate([System.Security.Principal.NTAccount])
        }
    }

    End
    {
        return $Result
    }
}

<#

### Example ###

$Sid = @(
    "S-1-5-21-000000000-1111111111-222222222-500"
    "S-1-5-21-000000000-1111111111-222222222-1000"

# Example 1
Get-NTAccountFromSID -Sid $Sid

# Example 2
$Sid | Get-NTAccountFromSID

#>