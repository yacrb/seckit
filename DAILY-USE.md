# Daily Use

This is the command map for the SecKit workspace. Bootstrap installs launcher names
without the `.sh` extension. The original files remain under `scripts/`.

## Start of Session

```bash
git pull
git submodule sync --recursive
git submodule update --init --recursive
```

If you are on a fresh box or launchers are missing:

```bash
./bootstrap.sh
```

## Keep Open in VS Code

The folders worth pinning mentally are:

- `scripts/` for fast wrappers
- `cheatsheets/` for quick reference
- `tools/` for upstream tool repos
- `wordlists/` for fuzzing and payload lists

## Common Workflows

### Recon

Passive enum and live host probing:

```bash
subdomain-enum -d example.com
```

Port scan:

```bash
port-scan -t 10.10.10.10
```

Directory or file busting:

```bash
dir-bust -u https://target.tld -m dirs
```

Web fuzzing shortcut:

```bash
web-fuzz https://target.tld api
```

### Web

SQLi testing wrapper:

```bash
sqli-test -u 'https://target.tld/item.php?id=1'
```

Parameter discovery and fuzzing:

```bash
fuzz-params -u https://target.tld/app --discover
fuzz-params -u https://target.tld/app --param redirect --payload-set open-redirect
```

Useful tool repos already inside the workspace:

- `tools/web/sqlmap`
- `tools/web/ffuf`
- `tools/web/GraphQLmap`
- `tools/web/XSStrike`
- `tools/web/SSRFmap`
- `tools/web/jwt_tool`

### Linux Privilege Escalation

```bash
privesc-check
```

Review first:

- `sudo.txt`
- `suid.txt`
- `capabilities.txt`
- `linpeas-highlights.txt`

### Forensics / IR

Volatility helper:

```bash
vol-autopsy dump.mem
```

PCAP triage:

```bash
pcap-triage capture.pcap
```

Linux host triage:

```bash
linux-triage
```

### CTF Helpers

Hash cracking helper:

```bash
hash-crack -f hashes.txt
```

Stego helper:

```bash
steg-check suspicious.png
```

Quick notes:

- `cheatsheets/ctf-quick-ref.md`
- `cheatsheets/reverse-shells.md`
- `cheatsheets/network-attacks.md`

## Output Habit

Most wrappers create their own output directories. Treat those as disposable run artifacts and keep your notes separate from raw output.

Examples:

- `subdomain-enum-*`
- `port-scan-*`
- `dir-bust-*`
- `sqli-test-*`
- `privesc-check-*`
- `pcap-triage-*`

## Wordlists

Main roots:

- `wordlists/SecLists`
- `wordlists/PayloadsAllTheThings`

## Update Loop

Normal refresh:

```bash
git pull
git submodule sync --recursive
git submodule update --init --recursive
```

If you want to pull tracked upstream tool branches forward manually:

```bash
git submodule sync --recursive
git submodule update --init --remote --recursive
```

## Practical Rule

If you are doing work and need something quickly, check in this order:

1. `scripts/`
2. `cheatsheets/`
3. `tools/`
4. `wordlists/`
