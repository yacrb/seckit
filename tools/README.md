# Tools Layout

`tools/` is split into automation-managed capability categories and platform-specific bundles:

- `recon`, `web`, `network`, `exploitation`, `post`, `forensics`, `crypto`, `cloud`, `malware`, `wireless`
  - Primary SecKit submodules and launcher targets.
- `windows`
  - Windows-only GUI binaries and suites that usually need vendor downloads.
- `cross`
  - Cross-platform support content such as `impacket`, `CyberChef`, and static binary collections.
- `linux`
  - Reserved for local or legacy Linux-only additions that are not part of the curated category tree.

The root `bootstrap.sh` treats category directories as the canonical source of tool installs and launcher links.
