#!/usr/bin/env bash
set -o pipefail

SECKIT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECKIT_ROOT="${SECKIT_ROOT:-$(cd "$SECKIT_LIB_DIR/../.." && pwd)}"
WORDLIST_ROOT="${SECKIT_WORDLIST_ROOT:-$SECKIT_ROOT/wordlists}"
SECLISTS_ROOT="${SECLISTS_ROOT:-$WORDLIST_ROOT/SecLists}"
PATT_ROOT="${PATT_ROOT:-$WORDLIST_ROOT/PayloadsAllTheThings}"
DEFAULT_ROCKYOU="${ROCKYOU_WORDLIST:-/usr/share/wordlists/rockyou.txt}"

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

need_file() {
    [ -f "$1" ] || die "Missing file: $1"
}

timestamp() {
    date +"%Y%m%d-%H%M%S"
}

make_outdir() {
    local prefix="$1"
    local outdir="${2:-./${prefix}-$(timestamp)}"

    mkdir -p "$outdir"
    printf '%s\n' "$outdir"
}

join_query() {
    local url="$1"
    local fragment="$2"

    if [[ "$url" == *\?* ]]; then
        printf '%s&%s\n' "$url" "$fragment"
    else
        printf '%s?%s\n' "$url" "$fragment"
    fi
}
