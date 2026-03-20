# SecKit

SecKit is a self-contained, auto-bootstrapping offensive + defensive toolkit repo for Kali, Ubuntu 22+, REMnux, and WSL2 workflows.

## Goal

```bash
git clone --recurse-submodules <repo>
cd seckit
./bootstrap.sh
```

One clone, one bootstrap, and the box is ready with curated tooling, launcher shortcuts, wordlists, wrappers, and cheatsheets.

## Layout

```text
seckit/
├── bootstrap.sh
├── cheatsheets/
├── scripts/
│   ├── crypto/
│   ├── ctf/
│   ├── forensics/
│   ├── lib/
│   ├── post/
│   ├── recon/
│   └── web/
├── tools/
│   ├── cloud/
│   ├── cross/
│   ├── crypto/
│   ├── exploitation/
│   ├── forensics/
│   ├── malware/
│   ├── network/
│   ├── post/
│   ├── recon/
│   ├── web/
│   ├── windows/
│   └── wireless/
└── wordlists/
```

`tools/windows/` remains the home for Windows-only GUI suites. Automation-managed offensive and defensive repos now live in capability-focused categories.

## Bootstrap

`bootstrap.sh` is idempotent and non-destructive:

- syncs and initializes git submodules
- installs apt and pip dependencies
- builds or wires supported tools into `~/bin` by default
- keeps third-party tool mirrors on tracked submodule branches
- refreshes `nuclei` templates when the launcher is available
- prints installed, skipped, failed, and manual-follow-up sections at the end

### Typical usage

```bash
git clone --recurse-submodules <repo>
cd seckit
chmod +x bootstrap.sh
./bootstrap.sh
```

### Notes

- Default launcher directory: `~/bin`
- Override launcher directory: `SECKIT_BIN_DIR=/usr/local/bin ./bootstrap.sh`
- Scheduled GitHub Actions can refresh submodule pointers from upstream tracked branches
- Wordlist root inside WSL: `/mnt/w/security/seckit/wordlists/`
- Existing files in the launcher directory are preserved rather than overwritten

## Registered Submodules

### Wordlists

- `wordlists/SecLists`
- `wordlists/PayloadsAllTheThings`

### Recon

- `tools/recon/subfinder`
- `tools/recon/amass`
- `tools/recon/httpx`
- `tools/recon/nuclei`
- `tools/recon/naabu`
- `tools/recon/gau`

### Web

- `tools/web/ffuf`
- `tools/web/GraphQLmap`
- `tools/web/sqlmap`
- `tools/web/XSStrike`
- `tools/web/SSRFmap`
- `tools/web/XXEinjector`
- `tools/web/jwt_tool`

### Post / Privilege Escalation

- `tools/post/PEASS-ng`
- `tools/post/PowerSploit`
- `tools/post/mimikatz`
- `tools/post/bettercap`

### Exploitation

- `tools/exploitation/AutoRecon`
- `tools/exploitation/exploitdb`

### Forensics

- `tools/forensics/volatility3`
- `tools/forensics/plaso`
- `tools/forensics/loki`
- `tools/forensics/sigma`

### Cloud

- `tools/cloud/ScoutSuite`
- `tools/cloud/pacu`
- `tools/cloud/prowler`

### Crypto / Cross-Platform

- `tools/crypto/pwntools`
- `tools/cross/impacket`
- `tools/cross/static-binaries`

## Script Wrappers

### Recon

```bash
subdomain-enum.sh -d example.com
port-scan.sh -t 10.10.10.10
dir-bust.sh -u https://target.tld -m dirs
web-fuzz.sh https://target.tld api
```

### Web

```bash
sqli-test.sh -u 'https://target.tld/item.php?id=1'
fuzz-params.sh -u https://target.tld/app --discover
fuzz-params.sh -u https://target.tld/app --param redirect --payload-set open-redirect
```

### Forensics / IR

```bash
vol-autopsy.sh dump.mem
pcap-triage.sh capture.pcap
linux-triage.sh
```

### Post / Crypto / CTF

```bash
privesc-check.sh
hash-crack.sh -f hashes.txt
steg-check.sh suspicious.png
```

## Cheatsheets

Existing:

- `volatility.md`
- `wireshark-filters.md`
- `windows-forensics.md`
- `linux-forensics.md`
- `log-analysis.md`
- `ctf-quick-ref.md`

Added:

- `cloud-aws.md`
- `active-directory.md`
- `privesc-linux.md`
- `privesc-windows.md`
- `reverse-shells.md`
- `network-attacks.md`

## Windows Tooling

Still expected to live under `tools/windows/`:

- `VolatilityWorkbench`
- `EricZimmermann`
- `FTKImager`
- `NetworkMiner`

These are intentionally left as user-managed downloads because vendor packaging and licensing change often.

## Manual Follow-Ups

- Download or refresh Windows-only GUI binaries in `tools/windows/`
- If your shell does not include `~/bin`, add it to `.bashrc`, `.zshrc`, or your profile of choice
