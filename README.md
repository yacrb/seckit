# SecKit

SecKit is a workspace-first security kit for CTFs, pentests, and day-to-day lab work.

The goal is simple: keep one VS Code folder open and always have the tools, wrappers, wordlists, and cheatsheets you actually reach for.

## Vision

SecKit is meant to be:

- ready to open in VS Code
- practical instead of over-engineered
- fast to bootstrap on Kali, Ubuntu 22+, REMnux, and WSL2
- easy to keep current as upstream tools move

This repo is the working kit, not just a catalog.

## Fast Start

```bash
git clone --recurse-submodules <repo>
cd seckit
./bootstrap.sh
```

After bootstrap, keep this repo open in VS Code and use it as the default workspace for:

- recon
- web testing
- privilege escalation
- forensics / IR
- CTF helper work

For the day-to-day command map, see [DAILY-USE.md](/mnt/w/security/seckit/DAILY-USE.md).

## Layout

```text
seckit/
├── .vscode/
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

`tools/windows/` remains the place for Windows-only GUI suites. The rest of the toolkit lives in capability-focused categories so the repo stays predictable.

## What You Get

### Curated Tool Mirrors

Tracked external repos live as submodules and are grouped by use case:

- wordlists: `SecLists`, `PayloadsAllTheThings`
- recon: `subfinder`, `amass`, `httpx`, `nuclei`, `naabu`, `gau`
- web: `ffuf`, `GraphQLmap`, `sqlmap`, `XSStrike`, `SSRFmap`, `XXEinjector`, `jwt_tool`
- post / privesc: `PEASS-ng`, `PowerSploit`, `mimikatz`, `bettercap`
- exploitation: `AutoRecon`, `exploitdb`
- forensics: `volatility3`, `plaso`, `loki`, `sigma`
- cloud: `ScoutSuite`, `pacu`, `prowler`
- crypto / cross-platform: `pwntools`, `impacket`, `static-binaries`

### Wrapper Scripts

Repo-local wrappers give you a faster path for common jobs:

- recon: `subdomain-enum.sh`, `port-scan.sh`, `dir-bust.sh`, `web-fuzz.sh`
- web: `sqli-test.sh`, `fuzz-params.sh`
- post: `privesc-check.sh`
- forensics: `vol-autopsy.sh`, `pcap-triage.sh`, `linux-triage.sh`
- crypto / CTF: `hash-crack.sh`, `steg-check.sh`

### Cheatsheets

Built-in notes stay in the same workspace:

- `active-directory.md`
- `cloud-aws.md`
- `ctf-quick-ref.md`
- `linux-forensics.md`
- `log-analysis.md`
- `network-attacks.md`
- `privesc-linux.md`
- `privesc-windows.md`
- `reverse-shells.md`
- `volatility.md`
- `windows-forensics.md`
- `wireshark-filters.md`

## Bootstrap

`bootstrap.sh` is idempotent and non-destructive. It:

- syncs and initializes git submodules
- installs apt and pip dependencies
- builds or wires supported tools into `~/bin` by default
- installs local wrappers and launcher links
- keeps third-party tool mirrors on tracked submodule branches
- refreshes `nuclei` templates when the launcher is available

Typical usage:

```bash
./bootstrap.sh
```

Notes:

- default launcher directory: `~/bin`
- override launcher directory: `SECKIT_BIN_DIR=/usr/local/bin ./bootstrap.sh`
- wordlist root in this workspace: `/mnt/w/security/seckit/wordlists/`
- existing launcher files are preserved rather than overwritten

## VS Code Workflow

The repo now includes a light workspace setup in `.vscode/`:

- recommended extensions for shell, markdown, and yaml work
- tasks for bootstrap, submodule sync, upstream refresh, and nuclei template refresh
- search / watcher exclusions for generated output noise

That keeps the repo more usable as a daily driver instead of just a storage tree.

## Updating

SecKit keeps upstream tool repos as submodules with tracked branches.

Local refresh:

```bash
git pull
git submodule sync --recursive
git submodule update --init --recursive
```

Manual upstream refresh of tracked tool mirrors:

```bash
git submodule sync --recursive
git submodule update --init --remote --recursive
```

The repo also includes a scheduled GitHub Actions workflow to refresh submodule pointers automatically.

## Windows Tooling

Still expected to live under `tools/windows/`:

- `VolatilityWorkbench`
- `EricZimmermann`
- `FTKImager`
- `NetworkMiner`

These are intentionally left as user-managed downloads because vendor packaging and licensing change often.

## Manual Follow-Ups

- download or refresh Windows-only GUI binaries in `tools/windows/`
- if your shell does not include `~/bin`, add it to `.bashrc`, `.zshrc`, or your profile of choice
