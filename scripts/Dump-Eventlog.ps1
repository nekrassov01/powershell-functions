Function Dump-Eventlog
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
        [string]$ComputerName = "localhost",

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateSet(
            "Application",
            "System",
            "Security"
        )]
        [string[]]$LogName = @("Application","System"),

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [int[]]$Level = @(1,2,3),

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [int32]$Recently = 1,

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $false
        )]
        [int32[]]$EventId
    )

    Begin
    {
        $Result = New-Object -TypeName System.Collections.ArrayList
    }

    Process
    {
        $FilterHashTable = @{
            LogName   = $LogName
            Level     = $Level
            StartTime = (Get-Date).AddHours(-$Recently)
        }

        If($EventId)
        {
            $FilterHashTable.Add("Id", $EventId)
        }

        Get-WinEvent -ComputerName $ComputerName -FilterHashTable $FilterHashTable | ForEach-Object -Process {
            $Columns = @("ComputerName","LogName","LevelId","Level","EventId","Date","Time","Source","Keyword","Opcode","Task","User","Sid","Message")
            $Obj = New-Object -TypeName PSCustomObject | Select-Object $Columns

            $Obj."ComputerName" = If($Null -ne $_.MachineName        ){[string]$_.MachineName}
            $Obj."LogName"      = If($Null -ne $_.LogName            ){[string]$_.LogName}
            $Obj."LevelId"      = If($Null -ne $_.Level              ){[string]$_.Level}
            $Obj."Level"        = If($Null -ne $_.LevelDisplayName   ){[string]$_.LevelDisplayName}
            $Obj."EventId"      = If($Null -ne $_.Id                 ){[string]$_.Id}
            $Obj."Date"         = If($Null -ne $_.TimeCreated        ){[string]$_.TimeCreated.ToString("yyyy-MM-dd")}
            $Obj."Time"         = If($Null -ne $_.TimeCreated        ){[string]$_.TimeCreated.ToString("HH:mm:ss")}
            $Obj."Source"       = If($Null -ne $_.ProviderName       ){[string]$_.ProviderName}
            $Obj."Keyword"      = If($Null -ne $_.KeywordsDisplayName){[string]$_.KeywordsDisplayName}
            $Obj."Opcode"       = If($Null -ne $_.OpcodeDisplayName  ){[string]$_.OpcodeDisplayName}
            $Obj."Task"         = If($Null -ne $_.TaskDisplayName    ){[string]$_.TaskDisplayName}
            $Obj."User"         = If($Null -ne $_.UserId             ){Try{[string]$_.UserId.Translate([System.Security.Principal.NTAccount]).Value}Catch{}}
            $Obj."Sid"          = If($Null -ne $_.UserId             ){[string]$_.UserId}
            $Obj."Message"      = If($Null -ne $_.Message            ){[string]$_.Message.Replace("`r`n","`n").Replace("`r","`n").Replace("`n"," ").Replace("`t"," ")}

            $Result += $Obj
        }
    }

    End
    {
        return $Result
    }
}

<#

### Examples ###

# Example 1
$Params1 = @{
    ComputerName = "localhost"
    LogName      = "System", "Application"
    Level        = 1,2,3
    Recently     = 24*7
}
Dump-Eventlog @Params1

# Example 2
$Params2 = @{
    ComputerName = "localhost"
    LogName      = "Security"
    Level        = 0
    Recently     = 24
    EventId      = 4624,4672
}
Dump-Eventlog @Params2

# Example 3
$Params3 = @{
    LogName      = "System", "Application"
    Level        = 1,2,3
    Recently     = 24*7
}
"127.0.0.1" | Dump-Eventlog @Params3

# Example 4
$Params4 = @{
    ComputerName = "localhost"
    Level        = 1,2,3
    Recently     = 24*7
}
"System", "Application" | Dump-Eventlog @Params4

#>