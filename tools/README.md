# Tools Layout

`tools/` is split into automation-managed capability categories and platform-specific bundles:

- `recon`, `web`, `exploitation`, `post`, `forensics`, `crypto`, `cloud`
  - Primary SecKit submodules and launcher targets.
- `windows`
  - Windows-only GUI binaries and suites that usually need vendor downloads.
- `cross`
  - Cross-platform support content such as `impacket`, `CyberChef`, and static binary collections.

The root `bootstrap.sh` treats these categories as the canonical source of tool installs and launcher links.

If new capability areas are added later, prefer adding them when they contain real tooling instead of keeping placeholder directories around.
