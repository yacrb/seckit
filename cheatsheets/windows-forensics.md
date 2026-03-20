# Windows Forensics Cheatsheet

## Key Artifact Locations

### Execution evidence
| Artifact | Path |
|----------|------|
| Prefetch | `C:\Windows\Prefetch\*.pf` |
| ShimCache | `SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache` |
| AmCache | `C:\Windows\AppCompat\Programs\Amcache.hve` |
| BAM/DAM | `SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\` |
| UserAssist | `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist` |
| MUI Cache | `NTUSER.DAT\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache` |
| JumpLists | `%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\` |

### Persistence locations
```
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Run
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\RunOnce
SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon        # Userinit, Shell
SYSTEM\CurrentControlSet\Services\                           # services
SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options  # debugger hijack
```

### User activity
| Artifact | Path |
|----------|------|
| Recent files (LNK) | `%APPDATA%\Microsoft\Windows\Recent\` |
| Shellbags | `NTUSER.DAT\Software\Microsoft\Windows\Shell\BagMRU` |
| TypedPaths | `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths` |
| WordWheelQuery | `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery` |
| Last visited | `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32` |

### Network
| Artifact | Path |
|----------|------|
| Network history | `SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList` |
| Wi-Fi profiles | `C:\ProgramData\Microsoft\Wlansvc\Profiles\` |
| DNS cache | `ipconfig /displaydns` (live only) |

### Browser artifacts
```
Chrome:  %LOCALAPPDATA%\Google\Chrome\User Data\Default\
Firefox: %APPDATA%\Mozilla\Firefox\Profiles\<profile>\
Edge:    %LOCALAPPDATA%\Microsoft\Edge\User Data\Default\
```
Files of interest: `History`, `Cookies`, `Login Data`, `Cache/`

### USB / External devices
```
SYSTEM\CurrentControlSet\Enum\USBSTOR
SYSTEM\CurrentControlSet\Enum\USB
SOFTWARE\Microsoft\Windows Portable Devices\Devices
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
```

## Event Log Key Event IDs

| Event ID | Meaning |
|----------|---------|
| 4624 | Successful logon |
| 4625 | Failed logon |
| 4634/4647 | Logoff |
| 4648 | Logon with explicit credentials (runas) |
| 4672 | Special privileges assigned (admin logon) |
| 4688 | Process creation (requires audit policy) |
| 4698 | Scheduled task created |
| 4702 | Scheduled task updated |
| 4720 | User account created |
| 4732 | User added to local group |
| 4776 | NTLM authentication attempt |
| 7045 | New service installed |
| 7034 | Service crashed |
| 1102 | Audit log cleared |
| 4104 | PowerShell script block logging |

### Log file locations
```
C:\Windows\System32\winevt\Logs\
  Security.evtx
  System.evtx
  Application.evtx
  Microsoft-Windows-PowerShell%4Operational.evtx
  Microsoft-Windows-Sysmon%4Operational.evtx   (if Sysmon installed)
  Microsoft-Windows-TaskScheduler%4Operational.evtx
```

## Eric Zimmermann Tools Quick Reference

| Tool | Use |
|------|-----|
| `MFTECmd.exe` | Parse $MFT → CSV |
| `PECmd.exe` | Parse Prefetch files |
| `LECmd.exe` | Parse LNK files |
| `JLECmd.exe` | Parse JumpLists |
| `RECmd.exe` | Registry CLI parser |
| `Registry Explorer` | GUI registry browser |
| `Timeline Explorer` | View CSV output from above tools |
| `ShellBags Explorer` | GUI shellbags viewer |
| `AppCompatCacheParser.exe` | Parse ShimCache |
| `AmcacheParser.exe` | Parse Amcache.hve |

### Common commands
```powershell
# Parse MFT
MFTECmd.exe -f C:\$MFT --csv C:\output --csvf mft.csv

# Parse Prefetch
PECmd.exe -d C:\Windows\Prefetch --csv C:\output

# Parse LNK files
LECmd.exe -d "%APPDATA%\Microsoft\Windows\Recent" --csv C:\output

# Parse ShimCache
AppCompatCacheParser.exe -f SYSTEM --csv C:\output

# Parse Amcache
AmcacheParser.exe -f Amcache.hve --csv C:\output
```

## NTFS Artifacts
```
$MFT          — master file table, every file ever created
$LogFile      — NTFS journal (short term)
$UsnJrnl:$J   — USN journal (file create/modify/delete history)
$I30          — directory index (can show deleted files)
```

### Extract USN journal
```powershell
# Live system
fsutil usn readjournal C: > usn.txt

# From image — use MFTECmd
MFTECmd.exe -f '$J' --csv output/
```
