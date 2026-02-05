# Active Directory Security Monitoring Script
# Detects common attack patterns

param(
    [switch]$Continuous,
    [int]$IntervalSeconds = 60
)

function Write-Alert {
    param([string]$Message, [string]$Severity = "WARNING")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Severity) {
        "INFO" { "Green" }
        "WARNING" { "Yellow" }
        "CRITICAL" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] [$Severity] $Message" -ForegroundColor $color
}

function Check-KerberoastingAttempts {
    Write-Alert "Checking for Kerberoasting attempts..." "INFO"
    
    $kerbEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4769
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.Properties[8].Value -eq '0x17' # RC4 encryption
    }
    
    if ($kerbEvents.Count -gt 10) {
        Write-Alert "DETECTED: Possible Kerberoasting - $($kerbEvents.Count) TGS requests with RC4 encryption in last hour" "CRITICAL"
        
        $kerbEvents | Group-Object {$_.Properties[0].Value} | 
            Sort-Object Count -Descending | 
            Select-Object -First 5 | 
            ForEach-Object {
                Write-Alert "  - Account: $($_.Name), Count: $($_.Count)" "WARNING"
            }
    }
}

function Check-UnusualLoginPatterns {
    Write-Alert "Checking for unusual login patterns..." "INFO"
    
    $logins = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4624
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.Properties[8].Value -eq 3 # Network logon
    }
    
    $loginCounts = $logins | Group-Object {$_.Properties[5].Value} | 
        Sort-Object Count -Descending
    
    foreach ($account in $loginCounts | Select-Object -First 5) {
        if ($account.Count -gt 50) {
            Write-Alert "DETECTED: High login count for account: $($account.Name) - $($account.Count) logins" "CRITICAL"
        }
    }
}

function Check-FailedLogins {
    Write-Alert "Checking for failed login attempts..." "INFO"
    
    $failedLogins = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4625
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue
    
    if ($failedLogins.Count -gt 20) {
        Write-Alert "DETECTED: High number of failed logins - $($failedLogins.Count) attempts" "CRITICAL"
        
        $failedLogins | Group-Object {$_.Properties[5].Value} | 
            Sort-Object Count -Descending | 
            Select-Object -First 5 | 
            ForEach-Object {
                Write-Alert "  - Account: $($_.Name), Count: $($_.Count)" "WARNING"
            }
    }
}

function Check-ServiceAccountChanges {
    Write-Alert "Checking for service account modifications..." "INFO"
    
    $spnChanges = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 5136
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.Message -match "servicePrincipalName"
    }
    
    if ($spnChanges) {
        Write-Alert "DETECTED: SPN modifications - $($spnChanges.Count) changes" "WARNING"
        foreach ($change in $spnChanges | Select-Object -First 5) {
            Write-Alert "  - SPN change detected at $(Get-Date $change.TimeCreated -Format 'HH:mm:ss')" "WARNING"
        }
    }
}

function Check-AdminGroupChanges {
    Write-Alert "Checking for privileged group modifications..." "INFO"
    
    $groupChanges = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = @(4728, 4732, 4756)
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue
    
    if ($groupChanges) {
        Write-Alert "DETECTED: Privileged group membership changes - $($groupChanges.Count) modifications" "CRITICAL"
        foreach ($change in $groupChanges) {
            $member = $change.Properties[0].Value
            $group = $change.Properties[2].Value
            Write-Alert "  - User '$member' added to group '$group'" "CRITICAL"
        }
    }
}

function Check-LDAPQueries {
    Write-Alert "Checking for suspicious LDAP queries..." "INFO"
    
    # This requires Directory Service auditing to be enabled
    $ldapEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4662
        StartTime = (Get-Date).AddMinutes(-10)
    } -ErrorAction SilentlyContinue
    
    if ($ldapEvents.Count -gt 1000) {
        Write-Alert "DETECTED: High volume of LDAP queries - $($ldapEvents.Count) in 10 minutes" "WARNING"
    }
}

function Run-SecurityChecks {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "AD Security Monitoring - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Check-KerberoastingAttempts
    Check-UnusualLoginPatterns
    Check-FailedLogins
    Check-ServiceAccountChanges
    Check-AdminGroupChanges
    Check-LDAPQueries
    
    Write-Host "`n========================================`n" -ForegroundColor Cyan
}

# Main execution
if ($Continuous) {
    Write-Alert "Starting continuous monitoring (Interval: $IntervalSeconds seconds)..." "INFO"
    Write-Alert "Press Ctrl+C to stop" "INFO"
    
    while ($true) {
        Run-SecurityChecks
        Start-Sleep -Seconds $IntervalSeconds
    }
} else {
    Run-SecurityChecks
}
