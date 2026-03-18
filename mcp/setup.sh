#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_MCP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/seckit/mcp"

log() {
    printf '[*] %s\n' "$*"
}

warn() {
    printf '[!] %s\n' "$*" >&2
}

die() {
    printf '[-] %s\n' "$*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

detect_platform() {
    case "$(uname -s)" in
        Darwin) printf 'macos\n' ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                printf 'wsl\n'
            else
                printf 'linux\n'
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) printf 'windows\n' ;;
        *) printf 'unknown\n' ;;
    esac
}

claude_config_path() {
    local platform="$1"

    case "$platform" in
        macos)
            printf '%s\n' "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        linux)
            printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/Claude/claude_desktop_config.json"
            ;;
        wsl)
            local appdata_win
            appdata_win="$(powershell.exe -NoProfile -Command '$env:APPDATA' 2>/dev/null | tr -d '\r')"
            [ -n "$appdata_win" ] || die "Could not resolve Windows APPDATA from WSL."
            printf '%s\n' "$(wslpath "$appdata_win")/Claude/claude_desktop_config.json"
            ;;
        windows)
            [ -n "${APPDATA:-}" ] || die "APPDATA is not set."
            printf '%s\n' "$APPDATA/Claude/claude_desktop_config.json"
            ;;
        *)
            die "Unsupported platform."
            ;;
    esac
}

prompt_secret() {
    local label="$1"
    local value=""
    printf '%s: ' "$label" >&2
    read -r -s value
    printf '\n' >&2
    printf '%s' "$value"
}

write_local_config() {
    local template_file="$1"
    local output_file="$2"
    local github_token="${3:-}"
    local shodan_token="${4:-}"
    local vt_token="${5:-}"

    jq \
        --arg github_token "$github_token" \
        --arg shodan_token "$shodan_token" \
        --arg vt_token "$vt_token" \
        '
        walk(
            if type == "string" then
                gsub("__GITHUB_TOKEN__"; $github_token // "__GITHUB_TOKEN__")
                | gsub("__SHODAN_API_KEY__"; $shodan_token // "__SHODAN_API_KEY__")
                | gsub("__VT_API_KEY__"; $vt_token // "__VT_API_KEY__")
            else
                .
            end
        )
    ' "$template_file" >"$output_file"
    chmod 600 "$output_file"
}

merge_into_claude() {
    local destination="$1"
    shift

    local merged="$LOCAL_MCP_DIR/merged.json"
    local current="$LOCAL_MCP_DIR/current.json"

    if [ -f "$destination" ]; then
        cp "$destination" "$current"
    else
        printf '{\"mcpServers\":{}}\n' >"$current"
    fi

    jq -s '
        reduce .[] as $item (
            {"mcpServers": {}};
            .mcpServers += ($item.mcpServers // {})
        )
    ' "$current" "$@" >"$merged"

    mkdir -p "$(dirname "$destination")"
    cp "$destination" "$destination.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
    cp "$merged" "$destination"
}

main() {
    local platform
    local claude_config
    local github_token=""
    local shodan_token=""
    local vt_token=""
    local filesystem_local="$LOCAL_MCP_DIR/filesystem-local.json"
    local github_local="$LOCAL_MCP_DIR/github-local.json"
    local shodan_local="$LOCAL_MCP_DIR/shodan-local.json"
    local vt_local="$LOCAL_MCP_DIR/virustotal-local.json"
    local web_local="$LOCAL_MCP_DIR/web-search-local.json"

    need_cmd jq
    mkdir -p "$LOCAL_MCP_DIR"

    platform="$(detect_platform)"
    claude_config="$(claude_config_path "$platform")"

    log "Detected platform: $platform"
    log "Claude Desktop config: $claude_config"

    write_local_config "$SCRIPT_DIR/configs/filesystem.json" "$filesystem_local"

    github_token="$(prompt_secret 'Enter GITHUB_TOKEN (leave blank to skip GitHub merge)')"
    if [ -n "$github_token" ]; then
        write_local_config "$SCRIPT_DIR/configs/github.json" "$github_local" "$github_token"
    fi

    shodan_token="$(prompt_secret 'Enter SHODAN_API_KEY (leave blank to build placeholder only)')"
    write_local_config "$SCRIPT_DIR/configs/shodan.json" "$shodan_local" "" "$shodan_token"

    vt_token="$(prompt_secret 'Enter VT_API_KEY (leave blank to build placeholder only)')"
    write_local_config "$SCRIPT_DIR/configs/virustotal.json" "$vt_local" "" "" "$vt_token"

    cp "$SCRIPT_DIR/configs/web-search.json" "$web_local"
    chmod 600 "$web_local"

    if [ -n "$github_token" ]; then
        merge_into_claude "$claude_config" "$filesystem_local" "$github_local"
    else
        merge_into_claude "$claude_config" "$filesystem_local"
    fi

    cat <<EOF
Local configs written to: $LOCAL_MCP_DIR
Merged Claude config    : $claude_config

Merged automatically:
  - filesystem
$( [ -n "$github_token" ] && printf '  - github\n' )
Not merged automatically:
  - shodan (fill in command placeholders in $shodan_local)
  - virustotal (fill in command placeholders in $vt_local)
  - web-search (fill in command placeholders in $web_local)

Next steps:
  1. Review the generated local JSON files.
  2. Add real server commands for placeholder servers if you plan to enable them.
  3. Restart Claude Desktop after the config change.
EOF
}

main "$@"
