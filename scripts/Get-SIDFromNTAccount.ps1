<#

.Synopsis
Convert NTAccount to SID

.DESCRIPTION
Convert NTAccount to SID

.EXAMPLE
Get-SIDFromNTAccount -NTAccount "$env:COMPUTERNAME\User-01", "$env:USERDOMAIN\User-02"

.EXAMPLE
"$env:COMPUTERNAME\User-01", "$env:USERDOMAIN\User-02" | Get-SIDFromNTAccount

.NOTES
Author: nekrassov01

#>

Function Get-SIDFromNTAccount
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
        [string[]]$NTAccount
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $NTAccount | ForEach-Object -Process {
            $Obj = [System.Security.Principal.NTAccount]$_
            $Result += $Obj.Translate([System.Security.Principal.SecurityIdentifier])
        }
    }

    End
    {
        return $Result
    }
}
