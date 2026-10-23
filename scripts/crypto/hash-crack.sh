#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: hash-crack.sh -f <hash_file> [--mode auto|brute|rules] [--hash-type <hashcat_mode>] [-w <wordlist>] [--mask <mask>] [-o <output_dir>]

Examples:
  hash-crack.sh -f hashes.txt
  hash-crack.sh -f hashes.txt --mode rules --hash-type 1000
  hash-crack.sh -f hashes.txt --mode brute --hash-type 1400 --mask '?u?l?l?l?l?d?d?d'
EOF
}

HASH_FILE=""
CRACK_MODE="auto"
HASHCAT_MODE=""
WORDLIST="$DEFAULT_ROCKYOU"
MASK='?a?a?a?a?a?a?a?a'
OUTDIR=""

while [ $# -gt 0 ]; do
    case "$1" in
        -f|--file)
            HASH_FILE="$2"
            shift 2
            ;;
        --mode)
            CRACK_MODE="$2"
            shift 2
            ;;
        --hash-type)
            HASHCAT_MODE="$2"
            shift 2
            ;;
        -w|--wordlist)
            WORDLIST="$2"
            shift 2
            ;;
        --mask)
            MASK="$2"
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

[ -n "$HASH_FILE" ] || { usage; exit 1; }
need_file "$HASH_FILE"
need_cmd hashcat

detect_hashcat_mode() {
    local sample
    sample="$(grep -v '^[[:space:]]*$' "$HASH_FILE" | head -n 1)"
    [ -n "$sample" ] || return 1

    if command -v hashid >/dev/null 2>&1; then
        hashid -m "$sample" 2>/dev/null | awk '/Hashcat Mode:/ {print $NF; exit}'
    fi
}

if [ -z "$HASHCAT_MODE" ]; then
    HASHCAT_MODE="$(detect_hashcat_mode || true)"
fi

[ -n "$HASHCAT_MODE" ] || die "Could not determine hashcat mode automatically. Use --hash-type."
OUTDIR="$(make_outdir "hash-crack" "$OUTDIR")"

SESSION_NAME="seckit-$(timestamp)"
HASHCAT_ARGS=(-m "$HASHCAT_MODE" --session "$SESSION_NAME" --outfile "$OUTDIR/cracked.txt" --potfile-path "$OUTDIR/hashcat.potfile" --status)

case "$CRACK_MODE" in
    auto)
        need_file "$WORDLIST"
        hashcat "${HASHCAT_ARGS[@]}" -a 0 "$HASH_FILE" "$WORDLIST" | tee "$OUTDIR/hashcat.log"
        ;;
    rules)
        need_file "$WORDLIST"
        hashcat "${HASHCAT_ARGS[@]}" -a 0 "$HASH_FILE" "$WORDLIST" -r /usr/share/hashcat/rules/best64.rule | tee "$OUTDIR/hashcat.log"
        ;;
    brute)
        hashcat "${HASHCAT_ARGS[@]}" -a 3 "$HASH_FILE" "$MASK" | tee "$OUTDIR/hashcat.log"
        ;;
    *)
        die "Unsupported crack mode: $CRACK_MODE"
        ;;
esac

hashcat -m "$HASHCAT_MODE" "$HASH_FILE" --show --potfile-path "$OUTDIR/hashcat.potfile" >"$OUTDIR/show.txt" 2>/dev/null || true

cat <<EOF
Output directory : $OUTDIR
Hashcat mode     : $HASHCAT_MODE
Attack mode      : $CRACK_MODE
Recovered hashes : $(wc -l <"$OUTDIR/show.txt" 2>/dev/null || echo 0)
EOF
