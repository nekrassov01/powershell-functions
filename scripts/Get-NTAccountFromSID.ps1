### Requires -Version 5.1 ###

<#
.Synopsis
Convert SID to NTAccount

.DESCRIPTION
Convert SID to NTAccount

.EXAMPLE
Get-NTAccountFromSID -Sid "S-1-5-21-000000000-1111111111-222222222-500", "S-1-5-21-000000000-1111111111-222222222-1000"

.EXAMPLE
"S-1-5-21-000000000-1111111111-222222222-500", "S-1-5-21-000000000-1111111111-222222222-1000" | Get-NTAccountFromSID

.NOTES
Author: nekrassov01
#>

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
