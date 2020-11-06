Function Backup-ScheduledTask
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
        [string[]]$TaskFolder,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = "localhost",

        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Destination = $PSScriptRoot
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
        $TaskSched = New-Object -ComObject Schedule.Service
    }

    Process
    {
        $TaskFolder | ForEach-Object -Process {

            $_TaskFolder = $_

            $TaskSched.Connect($ComputerName)
            $TaskSched.GetFolder($_TaskFolder).GetTasks(0) | ForEach-Object -Process {

                $Obj = New-Object -TypeName PSCustomObject | Select-Object -Property "ComputerName", "TaskFolder", "TaskName", "Result"
                $Obj."ComputerName" = $ComputerName
                $Obj."TaskFolder" = $_TaskFolder
                $Obj."TaskName" = $_.Name

                $OutputFile = ($Destination | Join-Path -ChildPath $_.Name) + ".xml"
                $_.Xml | Out-File -FilePath $OutputFile -Encoding utf8

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

### Example ###

$TaskFolder = @(
    "\Spcc"
    "\WSL"
)

# Example 1
Backup-ScheduledTask -TaskFolder $TaskFolder

# Example 2
Backup-ScheduledTask -TaskFolder $TaskFolder -ComputerName RemoteHost

# Example 3
Backup-ScheduledTask -TaskFolder $TaskFolder -ComputerName RemoteHost -Destination C:\temp

# Example 4
$TaskFolder | Backup-ScheduledTask

# Example 5
$TaskFolder | Backup-ScheduledTask -ComputerName RemoteHost

# Example 6
$TaskFolder | Backup-ScheduledTask -ComputerName RemoteHost -Destination C:\temp

#>