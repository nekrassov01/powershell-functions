Function Remove-UserProfile
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
        [string[]]$UserAccount,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = "localhost"
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $UserAccount | ForEach-Object -Process {
            $NTAccount = [System.Security.Principal.NTAccount]$_
            $Sid = $NTAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
            $Target = Get-CimInstance -ClassName Win32_UserProfile -ComputerName $ComputerName | Where-Object -FilterScript { $_.SID -eq $Sid }
            $Target | Remove-CimInstance -WhatIf
            $Result += $NTAccount.Value
        }
    }

    End
    {
        return $Result
    }
}

### Example ###

$UserAccount = @(
    "User-01"
    "User-02"
)

# Example 1
Remove-UserProfile -UserAccount $UserAccount

# Example 2
#Remove-UserProfile -UserAccount $UserAccount -ComputerName "RemoteHost"

# Example 3
#$UserAccount | Remove-UserProfile

# Example 4
#$UserAccount | Remove-UserProfile -ComputerName "RemoteHost"