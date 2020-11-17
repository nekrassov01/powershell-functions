### Requires -Version 5.1 ###

<#
.Synopsis
Backup MSFT_ScheduledTask in XML Format

.DESCRIPTION
Backup MSFT_ScheduledTask in XML Format

.EXAMPLE
Backup-ScheduledTask -TaskFolder "\task_1", "\task_2"

.EXAMPLE
Backup-ScheduledTask -TaskFolder "\task_1", "\task_2" -ComputerName RemoteHost

.EXAMPLE
Backup-ScheduledTask -TaskFolder "\task_1", "\task_2" -ComputerName RemoteHost -Destination C:\temp

.EXAMPLE
 "\task_1", "\task_2" | Backup-ScheduledTask

.EXAMPLE
 "\task_1", "\task_2" | Backup-ScheduledTask -ComputerName RemoteHost

.EXAMPLE
 "\task_1", "\task_2" | Backup-ScheduledTask -ComputerName RemoteHost -Destination C:\temp

.NOTES
Author: nekrassov01
#>

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
