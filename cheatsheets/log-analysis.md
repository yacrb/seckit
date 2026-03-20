# Log Analysis Cheatsheet

## Windows Event Log Analysis

### PowerShell one-liners (live system)
```powershell
# Failed logons in last 24h
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=(Get-Date).AddHours(-24)}

# Process creation (requires process audit enabled)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688} | Select -First 50 | Format-List

# New services installed
Get-WinEvent -FilterHashtable @{LogName='System'; Id=7045}

# PowerShell script block logging
Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' | Where-Object {$_.Id -eq 4104} | Select -First 20

# Cleared logs
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=1102}
```

### Grep patterns for exported .evtx → CSV
```bash
# Lateral movement indicators
grep -i "4648\|4624.*3\b" security.csv    # explicit creds / network logon

# Privilege escalation
grep "4672" security.csv                  # special privileges

# Persistence
grep "7045\|4698" system.csv             # new service / scheduled task
```

## Linux Log Analysis

### Auth.log patterns
```bash
# Failed SSH attempts
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Successful SSH logins
grep "Accepted" /var/log/auth.log

# Sudo commands
grep "COMMAND" /var/log/auth.log

# New user created
grep "useradd\|adduser" /var/log/auth.log
```

### Apache/Nginx access log patterns
```bash
# Top IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head 20

# Top URIs
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head 20

# 4xx/5xx errors
awk '$9 ~ /^[45]/' access.log

# SQLi patterns
grep -iE "union.*select|or.*1=1|'--|%27|%3D" access.log

# LFI patterns
grep -iE "\.\./|etc/passwd|proc/self" access.log

# Webshell POST activity
awk '$6 == "\"POST"' access.log | awk '{print $7}' | sort | uniq -c | sort -rn

# Large response sizes (potential exfil)
awk '{print $10, $7}' access.log | sort -rn | head 20
```

## Splunk SPL Quick Reference

```splunk
# Basic search
index=* sourcetype=WinEventLog EventCode=4625

# Time range
index=* earliest=-24h latest=now

# Top values
index=* | top limit=20 src_ip

# Stats
index=* EventCode=4624 | stats count by user, src_ip | sort -count

# Timeline
index=* | timechart count by EventCode

# Failed then success (brute force detection)
index=* EventCode=4625 | stats count as failures by src_ip
| join src_ip [search index=* EventCode=4624 | stats count as successes by src_ip]
| where failures > 10 AND successes > 0

# Rare processes
index=* EventCode=4688 | rare limit=20 process_name

# Search for encoded PowerShell
index=* | search "*-EncodedCommand*" OR "*-enc *"

# Lateral movement
index=* EventCode=4624 Logon_Type=3 | stats count by src_ip, dest, user
```

## Elastic/KQL Quick Reference

```kql
# Basic
event.code: "4625"

# AND / OR
event.code: "4624" AND winlog.event_data.LogonType: "3"

# Wildcard
process.command_line: *base64*

# Range
@timestamp >= "2024-01-01" and @timestamp <= "2024-01-31"

# Exists
user.name: *

# Exclude
NOT event.code: "4634"
```

### Useful Elastic fields (Windows)
```
winlog.event_id
winlog.event_data.SubjectUserName
winlog.event_data.TargetUserName
winlog.event_data.IpAddress
winlog.event_data.LogonType
winlog.event_data.ProcessName
winlog.event_data.CommandLine
winlog.channel
```

## Logon Types Reference
| Type | Meaning |
|------|---------|
| 2 | Interactive (local console) |
| 3 | Network (SMB, mapped drive) |
| 4 | Batch (scheduled task) |
| 5 | Service |
| 7 | Unlock |
| 8 | NetworkCleartext (plaintext over network) |
| 9 | NewCredentials (runas /netonly) |
| 10 | RemoteInteractive (RDP) |
| 11 | CachedInteractive (offline domain logon) |

## IOC Extraction Patterns

### From logs (grep/sed)
```bash
# Extract IPs
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' file.log | sort -u

# Extract domains
grep -oE '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.log | sort -u

# Extract URLs
grep -oE 'https?://[^ ]+' file.log | sort -u

# Extract hashes (MD5)
grep -oE '[0-9a-fA-F]{32}' file.log | sort -u

# Extract hashes (SHA256)
grep -oE '[0-9a-fA-F]{64}' file.log | sort -u
```
