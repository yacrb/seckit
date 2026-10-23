#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  fuzz-params.sh -u <url> [--discover] [-o <output_dir>] [-w <param_wordlist>] [--value <marker>]
  fuzz-params.sh -u <url> --param <name> --payload-set <open-redirect|sqli|xss> [-o <output_dir>]

Modes:
  --discover               Fuzz parameter names with a SecLists parameter list.
  --param <name>           Fuzz one existing parameter with PayloadsAllTheThings payload wordlists.
EOF
}

URL=""
OUTDIR=""
DISCOVER=1
PARAM_NAME=""
PARAM_WORDLIST="$SECLISTS_ROOT/Discovery/Web-Content/burp-parameter-names.txt"
MARKER_VALUE="seckit"
PAYLOAD_SET=""

payload_wordlist() {
    case "$1" in
        open-redirect) printf '%s\n' "$PATT_ROOT/Open Redirect/Intruder/open_redirect_wordlist.txt" ;;
        sqli) printf '%s\n' "$PATT_ROOT/SQL Injection/Intruder/payloads-sql-blind-MySQL-WHERE" ;;
        xss) printf '%s\n' "$PATT_ROOT/XSS Injection/Intruders/xss_payloads_quick.txt" ;;
        *) return 1 ;;
    esac
}

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        --discover)
            DISCOVER=1
            shift
            ;;
        --param)
            PARAM_NAME="$2"
            DISCOVER=0
            shift 2
            ;;
        --payload-set)
            PAYLOAD_SET="$2"
            shift 2
            ;;
        --value)
            MARKER_VALUE="$2"
            shift 2
            ;;
        -w|--wordlist)
            PARAM_WORDLIST="$2"
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

[ -n "$URL" ] || { usage; exit 1; }
need_cmd ffuf

OUTDIR="$(make_outdir "fuzz-params" "$OUTDIR")"

if [ "$DISCOVER" -eq 1 ]; then
    need_file "$PARAM_WORDLIST"
    ffuf -u "$(join_query "$URL" 'FUZZ='"$MARKER_VALUE")" \
        -w "$PARAM_WORDLIST" \
        -mc 200,204,301,302,307,401,403 \
        -c \
        -of json \
        -o "$OUTDIR/ffuf.json" \
        | tee "$OUTDIR/ffuf.log"

    cat <<EOF
Mode           : parameter discovery
Output         : $OUTDIR
Param wordlist : $PARAM_WORDLIST
EOF
    exit 0
fi

[ -n "$PARAM_NAME" ] || die "--param is required for value fuzzing mode"
[ -n "$PAYLOAD_SET" ] || die "--payload-set is required for value fuzzing mode"
PAYLOAD_WORDLIST="$(payload_wordlist "$PAYLOAD_SET" || true)"
[ -n "$PAYLOAD_WORDLIST" ] || die "Unsupported payload set: $PAYLOAD_SET"
need_file "$PAYLOAD_WORDLIST"

ffuf -u "$(join_query "$URL" "$PARAM_NAME=FUZZ")" \
    -w "$PAYLOAD_WORDLIST" \
    -mc all \
    -c \
    -of json \
    -o "$OUTDIR/ffuf.json" \
    | tee "$OUTDIR/ffuf.log"

cat <<EOF
Mode            : value fuzzing
Parameter       : $PARAM_NAME
Payload wordlist: $PAYLOAD_WORDLIST
Output          : $OUTDIR
EOF
