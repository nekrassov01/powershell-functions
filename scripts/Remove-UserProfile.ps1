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
        [string[]]$UserName,

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
        $UserName | ForEach-Object -Process {

            $NTAccount = [System.Security.Principal.NTAccount]$_
            $Sid = $NTAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value

            $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "ComputerName", "UserName", "SID", "Result"
            $Obj."ComputerName" = $ComputerName
            $Obj."UserName" = $_
            $Obj."SID" = $Sid
            
            $Target = Get-WmiObject -ClassName Win32_UserProfile -ComputerName $ComputerName | Where-Object -FilterScript { $_.SID -eq $Sid }
            $Target | Remove-WmiObject -WhatIf

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

    End
    {
        return $Result
    }
}

<#

### Example ###

$UserName = @(
    "User-01"
    "User-02"
)

# Example 1
Remove-UserProfile -UserName $UserName

# Example 2
Remove-UserProfile -UserName $UserName -ComputerName "RemoteHost"

# Example 3
$UserName | Remove-UserProfile

# Example 4
$UserName | Remove-UserProfile -ComputerName "RemoteHost"

#>