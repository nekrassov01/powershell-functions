<#

.Synopsis
Delete UserProfiles with WMI Class: Win32_UserProfile

.DESCRIPTION
Delete UserProfiles with WMI Class: Win32_UserProfile

.EXAMPLE
Remove-UserProfile -UserName "User-01", "User-02"

.EXAMPLE
Remove-UserProfile -UserName "User-01", "User-02" -ComputerName "RemoteHost"

.EXAMPLE
"User-01", "User-02" | Remove-UserProfile

.EXAMPLE
"User-01", "User-02" | Remove-UserProfile -ComputerName "RemoteHost"

.NOTES
Author: nekrassov01

#>

Function Remove-UserProfile
{
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess)]
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
            $Target | Remove-WmiObject

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
