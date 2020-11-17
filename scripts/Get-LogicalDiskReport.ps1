<#

.Synopsis
Get a Report of Logical Disks from WMI Class: Win32_LogicalDisk

.DESCRIPTION
Get a Report of Logical Disks from WMI Class: Win32_LogicalDisk
 - Get TotalSpace, FreeSpace, and UsedSpace in each Unit of MB, GB, TB
 - You Can Check If UsedSpace Exceeds Threshold

.EXAMPLE
$LogicalDisks = @(

@{
    ComputerName = "RemoteHost01"
    DeviceId = "C:"
    Threshold = 60
}
@{
    ComputerName = "RemoteHost01"
    DeviceId = "D:"
    Threshold = 70
}
@{
    ComputerName = "RemoteHost02"
    DeviceId = "C:"
    Threshold = 80
}
@{
    ComputerName = "RemoteHost02"
    DeviceId = "D:"
    Threshold = 90
}

)

Get-LogicalDiskReport -LogicalDisks $LogicalDisks

.NOTES
Author: nekrassov01

#>

Function Get-LogicalDiskReport
{
    [OutputType([System.Object])]
    [CmdletBinding()]
    Param
    (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$LogicalDisks
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
        $Date = (Get-Date).ToString("yyyy-MM-dd")
    }

    Process
    {
        $LogicalDisks | ForEach-Object -Process {

            $ComputerName = $_.ComputerName
            $DeviceId = $_.DeviceId
            $Threshold = $_.Threshold

            Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName | 
            Where-Object -FilterScript { $_.DeviceId -eq $DeviceId } |
            ForEach-Object -Process {
                $Columns = "Date","ComputerName","DeviceId",
                           "Total(MB)","Free(MB)","Used(MB)",
                           "Total(GB)","Free(GB)","Used(GB)",
                           "Total(TB)","Free(TB)","Used(TB)",
                           "Percentage","Threshold","State"
                $Obj = New-Object -TypeName PSCustomObject | Select-Object $Columns

                $Obj."Date"         = $Date
                $Obj."ComputerName" = $_.PSComputerName
                $Obj."DeviceId"     = $_.DeviceId
                $Obj."Total(MB)"    = [math]::Round($_.Size / 1MB,4)
                $Obj."Free(MB)"     = [math]::Round($_.FreeSpace / 1MB,4)
                $Obj."Used(MB)"     = [math]::Round(($_.Size - $_.FreeSpace) / 1MB,4)
                $Obj."Total(GB)"    = [math]::Round($_.Size / 1GB,4)
                $Obj."Free(GB)"     = [math]::Round($_.FreeSpace / 1GB,4)
                $Obj."Used(GB)"     = [math]::Round(($_.Size - $_.FreeSpace) / 1GB,4)
                $Obj."Total(TB)"    = [math]::Round($_.Size / 1TB,4)
                $Obj."Free(TB)"     = [math]::Round($_.FreeSpace / 1TB,4)
                $Obj."Used(TB)"     = [math]::Round(($_.Size - $_.FreeSpace) / 1TB,4)
                $Obj."Percentage"   = If($_.Size -and $_.FreeSpace){[math]::Round(((($_.Size - $_.FreeSpace) / ($_.Size))*100),4)}
                $Obj."Threshold"    = $Threshold
                $Obj."State"        = If($Obj."Percentage" -ge $Obj."Threshold"){"Warning"}Else{"Normal"}

                $Result += $Obj
            }
        }
    }

    End
    {
        return $Result
    }
}
