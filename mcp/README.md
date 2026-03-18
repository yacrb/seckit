# SecKit MCP Scaffold

## What MCP Is

MCP stands for Model Context Protocol. It gives an LLM client a structured way to connect to external tools and data sources such as local files, GitHub, search, threat intel, or internal systems.

For SecKit, that means Claude Desktop can be wired to:

- read and write files in your security workspace
- search code and repositories
- query external intel providers such as Shodan or VirusTotal
- use web-search style enrichment during triage or recon

## Claude Desktop Integration

Claude Desktop reads an `mcpServers` object from `claude_desktop_config.json`.

Typical config locations:

- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

SecKit ships:

- `servers.json`
  - human-readable recommended server list
- `configs/*.json`
  - copy/paste templates or setup inputs
- `setup.sh`
  - creates local, untracked config snippets and merges supported servers into Claude Desktop config

## Adding Servers Manually

Minimal pattern:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "W:\\security",
        "W:\\dev"
      ]
    }
  }
}
```

Each server usually needs:

- a `command`
- an `args` array
- optional `env` values for API keys or tokens

## Setup Workflow

```bash
cd mcp
./setup.sh
```

`setup.sh` will:

- detect Windows / WSL / macOS / Linux
- find the Claude Desktop config path
- build local `*-local.json` files outside git
- prompt for API keys where needed
- merge supported server stanzas into Claude Desktop config
- print restart instructions

## Security Considerations

- Treat every MCP server as code execution or data access, not just configuration.
- Only trust servers you understand and can inspect.
- Keep API keys out of tracked files and shell history.
- Use scoped tokens where possible.
- Restrict filesystem access to directories you actually need.
- Review generated Claude config before enabling network-facing servers.
