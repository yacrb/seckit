#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: dir-bust.sh -u <url> [-m dirs|files|api|vhosts] [-o <output_dir>] [-w <wordlist>] [-d <base_domain>] [-x <exts>]

Examples:
  dir-bust.sh -u https://target.tld -m dirs
  dir-bust.sh -u https://target.tld -m files -x php,txt,bak
  dir-bust.sh -u http://10.10.10.10 -m vhosts -d example.com
EOF
}

MODE="dirs"
URL=""
OUTDIR=""
WORDLIST=""
BASE_DOMAIN=""
EXTENSIONS="php,txt,bak,old,zip,tar.gz"
THREADS=50
MATCH_CODES="200,204,301,302,307,401,403,405"

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        -w|--wordlist)
            WORDLIST="$2"
            shift 2
            ;;
        -d|--domain)
            BASE_DOMAIN="$2"
            shift 2
            ;;
        -x|--extensions)
            EXTENSIONS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown argument: $1"
            ;;
    esac
done

[ -n "$URL" ] || { usage; exit 1; }
need_cmd ffuf

case "$MODE" in
    dirs)
        WORDLIST="${WORDLIST:-$SECLISTS_ROOT/Discovery/Web-Content/raft-medium-directories.txt}"
        TARGET_URL="${URL%/}/FUZZ"
        ;;
    files)
        WORDLIST="${WORDLIST:-$SECLISTS_ROOT/Discovery/Web-Content/raft-medium-files.txt}"
        TARGET_URL="${URL%/}/FUZZ"
        ;;
    api)
        WORDLIST="${WORDLIST:-$SECLISTS_ROOT/Discovery/Web-Content/api/api-endpoints.txt}"
        TARGET_URL="${URL%/}/FUZZ"
        ;;
    vhosts)
        WORDLIST="${WORDLIST:-$SECLISTS_ROOT/Discovery/DNS/subdomains-top1million-5000.txt}"
        [ -n "$BASE_DOMAIN" ] || die "vhosts mode requires -d <base_domain>"
        TARGET_URL="${URL%/}/"
        ;;
    *)
        die "Unsupported mode: $MODE"
        ;;
esac

need_file "$WORDLIST"
OUTDIR="$(make_outdir "dir-bust-$MODE" "$OUTDIR")"

FFUF_ARGS=(-u "$TARGET_URL" -w "$WORDLIST" -mc "$MATCH_CODES" -t "$THREADS" -c -of json -o "$OUTDIR/ffuf.json")

if [ "$MODE" = "files" ]; then
    FFUF_ARGS+=(-e "$EXTENSIONS")
fi

if [ "$MODE" = "vhosts" ]; then
    FFUF_ARGS+=(-H "Host: FUZZ.$BASE_DOMAIN")
fi

ffuf "${FFUF_ARGS[@]}" | tee "$OUTDIR/ffuf.log"

cat <<EOF
Output directory : $OUTDIR
Mode             : $MODE
Wordlist         : $WORDLIST
EOF
