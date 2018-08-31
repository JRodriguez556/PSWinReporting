# Collects all named paramters (all others end up in $Args)
param(
    $eventid = 4725,
    $eventRecordID = 1507624, # 425358 ,
    $eventChannel,
    $eventSeverity
)
<#
Update-Module PSTeams
Update-Module PSEventViewer
Update-Module PSWinReporting
Update-Module PSWriteColor
Update-Module ImportExcel
Update-Module PSSlack
Update-Module DBATools
#>
Import-Module PSTeams
Import-Module PSEventViewer
Import-Module PSWinReporting -Force
Import-Module PSWriteColor
Import-Module PSSlack
Import-Module DBATools

$ReportOptions = @{
    JustTestPrerequisite  = $false # runs testing without actually running script

    AsExcel               = $true # attaches Excel to email with all events, required ImportExcel module
    AsCSV                 = $false # attaches CSV to email with all events,
    AsHTML                = $true # puts exported data into email directly with all events
    SendMail              = $false
    OpenAsFile            = $true # requires AsHTML set to $true
    KeepReports           = $true # keeps files after reports are sent (only if AssExcel/AsCSV are in use)
    KeepReportsPath       = 'C:\Support\Reports\ExportedEvents' # if empty, temp path is used
    FilePattern           = 'Evotec-ADMonitoredEvents-<currentdate>.<extension>'
    FilePatternDateFormat = 'yyyy-MM-dd-HH_mm_ss'

    DisplayConsole        = @{
        ShowTime   = $false
        LogFile    = ''
        TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    }
    Debug                 = @{
        DisplayTemplateHTML = $false
        Verbose             = $false
    }
    Notifications         = @{
        MicrosoftTeams = @{
            Use     = $false
            TeamsID = ''
        }
        Slack          = @{
            Use     = $false
            Channel = '#general'
            Uri     = ""
        }
        MSSQL          = @{
            Use          = $true
            Server       = 'EVO1'
            Database     = 'SSAE18'
            Table        = ''
            TableMapping = [ordered] @{
                'ID'                  = '<PrimaryKey>'
                'EventType'           = ''
                'EventID'             = 'Event ID'
                'EventWho'            = 'Who'
                'EventWhen'           = 'When'
                'EventRecordID'       = 'Record ID'
                'DomainController'    = 'Domain Controller'
                'Action'              = 'Action'
                'GroupName'           = ''
                'UserAffected'        = 'User Affected'
                'MemberName'          = ''
                'ComputerLockoutOn'   = ''
                'ReportedBy'          = ''
                'SamAccountName'      = ''
                'DisplayName'         = ''
                'UserPrincipalName'   = ''
                'HomeDirectory'       = ''
                'HomePath'            = ''
                'ScriptPath'          = ''
                'ProfilePath'         = ''
                'UserWorkstation'     = ''
                'PasswordLastSet'     = ''
                'AccountExpires'      = ''
                'PrimaryGroupId'      = ''
                'AllowedToDelegateTo' = ''
                'OldUacValue'         = ''
                'NewUacValue'         = ''
                'UserAccountControl'  = ''
                'UserParameters'      = ''
                'SidHistory'          = ''
                'LogonHours'          = ''
                'OperationType'       = ''
                'Message'             = ''
                'BackupPath'          = ''
                'LogType'             = ''
                'EventAdded'          = '<CurrentUserName>'
                'EventAddedWho'       = '<CurrentDateTime>'
            }
        }
    }
    Backup                = @{
        Use             = $true
        DestinationPath = 'C:\MyEvents\'
    }
}
$ReportDefinitions = @{
    TimeToGenerate = $false
    TeamsID        = ''

    ReportsAD      = @{
        Servers    = @{
            ForwardServer   = $env:COMPUTERNAME
            ForwardEventLog = 'ForwardedEvents'
        }
        EventBased = @{
            UserChanges            = @{
                Enabled     = $true
                Events      = 4720, 4738
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserStatus             = @{
                Enabled     = $true
                Events      = 4722, 4725, 4767, 4723, 4724, 4726
                LogName     = 'Security'
                IgnoreWords = @{
                    'Domain Controller' = ''
                    'Action'            = ''
                    'User Affected'     = 'Win-*', '*AD1$*'
                    'Who'               = ''
                    'When'              = ''
                    'Event ID'          = ''
                    'Record ID'         = ''
                }
            }
            UserLockouts           = @{
                Enabled     = $true
                Events      = 4740
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogon              = @{
                Enabled     = $false
                Events      = 4624
                LogName     = 'Security'
                IgnoreWords = ''
            }
            UserLogonKerberos      = @{
                Enabled     = $false
                Events      = 4768
                LogName     = 'Security'
                IgnoreWords = ''
            }
            GroupMembershipChanges = @{
                Enabled     = $true
                Events      = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupCreateDelete      = @{
                Enabled     = $true
                Events      = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
                LogName     = 'Security'
                IgnoreWords = @{
                    'Who' = '*ANONYMOUS*'
                }
            }
            GroupPolicyChanges     = @{
                Enabled     = $false
                Events      = 5136, 5137, 5141
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedSecurity    = @{
                Enabled     = $true
                Events      = 1102, 1105
                LogName     = 'Security'
                IgnoreWords = ''
            }
            LogsClearedOther       = @{
                Enabled     = $true
                Events      = 104
                LogName     = 'System'
                IgnoreWords = ''
            }
            EventsReboots          = @{
                Enabled     = $false
                Events      = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
                LogName     = 'System'
                IgnoreWords = ''
            }
        }
    }
}

Start-Notifications -ReportDefinitions $ReportDefinitions -ReportOptions $ReportOptions -EventID $EventID -EventRecordID $EventRecordID -EventChannel $EventChannel -Verbose