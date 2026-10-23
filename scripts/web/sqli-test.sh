#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: sqli-test.sh (-u <url> | -r <request_file>) [-o <output_dir>] [--data <post_data>] [--cookie <cookie>] [--risk <1-3>] [--level <1-5>] [--threads <n>]

Examples:
  sqli-test.sh -u 'https://target.tld/item.php?id=1'
  sqli-test.sh -r login.txt --data 'username=admin&password=test'
EOF
}

URL=""
REQUEST_FILE=""
OUTDIR=""
POST_DATA=""
COOKIE=""
RISK=2
LEVEL=3
THREADS=4

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -r|--request)
            REQUEST_FILE="$2"
            shift 2
            ;;
        --data)
            POST_DATA="$2"
            shift 2
            ;;
        --cookie)
            COOKIE="$2"
            shift 2
            ;;
        --risk)
            RISK="$2"
            shift 2
            ;;
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --threads)
            THREADS="$2"
            shift 2
            ;;
        -o|--output)
            OUTDIR="$2"
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

if [ -z "$URL" ] && [ -z "$REQUEST_FILE" ]; then
    usage
    exit 1
fi

SQLMAP_CMD=(sqlmap)
if ! command -v sqlmap >/dev/null 2>&1; then
    [ -f "$SECKIT_ROOT/tools/web/sqlmap/sqlmap.py" ] || die "sqlmap launcher missing. Run bootstrap.sh first."
    SQLMAP_CMD=(python3 "$SECKIT_ROOT/tools/web/sqlmap/sqlmap.py")
fi

OUTDIR="$(make_outdir "sqli-test" "$OUTDIR")"
ARGS=(--batch --random-agent --smart --risk="$RISK" --level="$LEVEL" --threads="$THREADS" --output-dir="$OUTDIR/sqlmap")

if [ -n "$URL" ]; then
    ARGS+=(-u "$URL")
fi

if [ -n "$REQUEST_FILE" ]; then
    need_file "$REQUEST_FILE"
    ARGS+=(-r "$REQUEST_FILE")
fi

if [ -n "$POST_DATA" ]; then
    ARGS+=(--data "$POST_DATA")
fi

if [ -n "$COOKIE" ]; then
    ARGS+=(--cookie "$COOKIE")
fi

"${SQLMAP_CMD[@]}" "${ARGS[@]}" | tee "$OUTDIR/sqlmap.log"

cat <<EOF
Output directory: $OUTDIR
SQLmap output  : $OUTDIR/sqlmap
EOF
