# Linux Forensics Cheatsheet

## Key Artifact Locations

### User activity
| Artifact | Path |
|----------|------|
| Bash history | `~/.bash_history` |
| Zsh history | `~/.zsh_history` |
| Recently used files | `~/.local/share/recently-used.xbel` |
| SSH known hosts | `~/.ssh/known_hosts` |
| SSH auth keys | `~/.ssh/authorized_keys` |
| Sudo usage | `/var/log/auth.log` or `/var/log/secure` |

### Execution & persistence
```
/etc/crontab
/etc/cron.d/
/var/spool/cron/crontabs/
~/.config/autostart/          # desktop autostart
/etc/rc.local
/etc/init.d/
/etc/systemd/system/          # systemd services
~/.bashrc / ~/.bash_profile   # shell persistence
/etc/profile.d/
/etc/ld.so.preload            # LD_PRELOAD persistence (stealthy)
```

### Logs
| Log | Location |
|-----|----------|
| Auth/sudo | `/var/log/auth.log` (Debian) `/var/log/secure` (RHEL) |
| Syslog | `/var/log/syslog` or `/var/log/messages` |
| Apache | `/var/log/apache2/` or `/var/log/httpd/` |
| Nginx | `/var/log/nginx/` |
| Cron | `/var/log/cron` |
| Last logins | `/var/log/lastlog` (binary) |
| Login history | `/var/log/wtmp` (binary) |
| Failed logins | `/var/log/btmp` (binary) |

### Read binary logs
```bash
last -f /var/log/wtmp          # login history
lastb -f /var/log/btmp         # failed logins
lastlog                        # last login per user
who /var/log/wtmp              # all logins
```

## Live Triage Commands

### System info
```bash
uname -a                       # OS + kernel
hostname
date
uptime
cat /etc/os-release
```

### Users
```bash
cat /etc/passwd                # all users
cat /etc/shadow                # password hashes (root)
cat /etc/sudoers
awk -F: '$3 == 0' /etc/passwd  # UID 0 accounts (root-level)
lastlog | grep -v "Never"      # users who have logged in
```

### Processes
```bash
ps auxf                        # process tree
ps aux --sort=-%cpu            # by CPU
lsof -i                        # open network connections
lsof -p <pid>                  # files opened by process
/proc/<pid>/cmdline            # command line of process
/proc/<pid>/exe                # symlink to executable
/proc/<pid>/maps               # memory maps
ls -la /proc/<pid>/fd/         # file descriptors
```

### Network
```bash
ss -tupn                       # active connections with PID
netstat -tupn                  # same (older)
ip a                           # interfaces
ip r                           # routing table
cat /etc/hosts
cat /etc/resolv.conf
arp -a                         # ARP cache
```

### Files
```bash
find / -mtime -1 -type f 2>/dev/null          # modified in last 24h
find / -perm -4000 -type f 2>/dev/null        # SUID binaries
find /tmp /var/tmp -type f 2>/dev/null        # files in temp dirs
find / -name ".*" -type f 2>/dev/null         # hidden files
stat <file>                                    # timestamps (atime/mtime/ctime)
```

### Installed software / packages
```bash
dpkg -l                        # Debian/Ubuntu
rpm -qa                        # RHEL/CentOS
pip list                       # Python packages
```

## Timestamp Forensics

```
mtime — last content modification
atime — last access (often disabled: noatime mount)
ctime — last metadata change (permissions, owner)
btime — birth/creation time (not always available)
```

```bash
stat file.txt
ls -la --time-style=full-iso
```

**Note:** ctime cannot be manually set with `touch`. If ctime != mtime, file metadata was changed after content modification — suspicious.

## Web Shell Indicators
```bash
# Find recently modified PHP/JSP files
find /var/www -name "*.php" -mtime -7
find /var/www -name "*.jsp" -mtime -7

# Find PHP with exec/system calls
grep -r "eval\|base64_decode\|system\|exec\|passthru\|shell_exec" /var/www/ --include="*.php"

# World-writable files in web root
find /var/www -perm -o+w -type f
```

## Memory Acquisition (Linux)
```bash
# LiME (loadable kernel module)
insmod lime.ko "path=/tmp/mem.lime format=lime"

# /proc/mem (limited)
dd if=/dev/mem of=mem.raw bs=1M
```

## Useful one-liners
```bash
# Who ran sudo and when
grep sudo /var/log/auth.log | grep COMMAND

# All cron jobs across users
for user in $(cut -d: -f1 /etc/passwd); do crontab -u $user -l 2>/dev/null | grep -v '^#' | sed "s/^/$user: /"; done

# Check for LD_PRELOAD abuse
cat /etc/ld.so.preload

# Hashes of running process executables
for pid in /proc/[0-9]*; do exe=$(readlink $pid/exe 2>/dev/null); [ -f "$exe" ] && md5sum "$exe"; done | sort -u
```
