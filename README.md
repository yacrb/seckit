# SecKit

Portable offensive/defensive toolkit. One clone, operational everywhere.

## Structure

```
seckit/
├── wordlists/
│   ├── SecLists/               # submodule
│   ├── PayloadsAllTheThings/   # submodule
│   └── custom/                 # your own lists
├── cheatsheets/                # synthesized references
├── tools/
│   ├── windows/                # GUI tools, run on host
│   │   ├── VolatilityWorkbench/
│   │   ├── EricZimmermann/     # Registry Explorer, MFTECmd, LECmd...
│   │   ├── FTKImager/
│   │   └── NetworkMiner/
│   ├── linux/                  # WSL/REMnux tools
│   │   ├── volatility3/        # submodule
│   │   ├── recon/
│   │   └── custom-scripts/
│   └── cross/                  # platform-agnostic
│       ├── CyberChef/          # offline build
│       └── impacket/           # submodule
└── scripts/
    ├── recon/
    │   └── web-fuzz.sh         # ffuf wrapper
    ├── forensics/
    │   ├── vol-autopsy.sh      # Volatility first-pass triage
    │   └── pcap-triage.sh      # PCAP first-pass triage
    └── ctf/
        └── steg-check.sh       # steg tool chain
```

## Bootstrap on a new machine

```bash
git clone --recurse-submodules git@github.com:yacrb/seckit.git
cd seckit

# If submodules weren't cloned
git submodule update --init --recursive
```

## Manual downloads (not in git — binaries)

| Tool | URL |
|------|-----|
| VolatilityWorkbench | https://www.osforensics.com/tools/volatility-workbench.html |
| Eric Zimmermann Suite | https://ericzimmerman.github.io |
| FTK Imager | https://www.exterro.com/ftk-imager |
| NetworkMiner | https://www.netresec.com/?page=NetworkMiner |
| CyberChef (offline) | https://github.com/gchq/CyberChef/releases |

Place each under `tools/windows/<toolname>/`.

## WSL path mapping

SecLists from WSL: `/mnt/w/security/seckit/wordlists/SecLists`
Scripts use this path — adjust if your drive letter differs.

## Scripts usage

```bash
# Memory forensics
./scripts/forensics/vol-autopsy.sh dump.mem

# PCAP triage
./scripts/forensics/pcap-triage.sh capture.pcap

# Web fuzzing
./scripts/recon/web-fuzz.sh http://target.com dirs
./scripts/recon/web-fuzz.sh http://target.com api

# Steg triage
./scripts/ctf/steg-check.sh image.png
```

## Cheatsheets to build

- [ ] volatility.md
- [ ] wireshark-filters.md
- [ ] windows-forensics.md
- [ ] linux-forensics.md
- [ ] log-analysis.md
- [ ] ctf-quick-ref.md
