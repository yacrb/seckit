#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: subdomain-enum.sh -d <domain> [-o <output_dir>] [--resolvers <file>] [--skip-amass]

Pipeline:
  1. subfinder passive enumeration
  2. amass passive enumeration (unless --skip-amass)
  3. dnsx validation / resolution
  4. httpx probing
EOF
}

DOMAIN=""
OUTDIR=""
RESOLVERS="$SECLISTS_ROOT/Miscellaneous/dns-resolvers.txt"
SKIP_AMASS=0

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        --resolvers)
            RESOLVERS="$2"
            shift 2
            ;;
        --skip-amass)
            SKIP_AMASS=1
            shift
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

[ -n "$DOMAIN" ] || { usage; exit 1; }
need_cmd subfinder
need_cmd dnsx
need_cmd httpx

if [ ! -f "$RESOLVERS" ]; then
    warn "Resolvers file not found at $RESOLVERS, dnsx will use its defaults."
    RESOLVERS=""
fi

OUTDIR="$(make_outdir "subdomain-enum-${DOMAIN//./-}" "$OUTDIR")"
SUBFINDER_OUT="$OUTDIR/subfinder.txt"
AMASS_OUT="$OUTDIR/amass.txt"
COMBINED_OUT="$OUTDIR/subdomains.txt"
RESOLVED_OUT="$OUTDIR/resolved.txt"
HTTPX_OUT="$OUTDIR/httpx.txt"

log "Enumerating passive subdomains for $DOMAIN"
subfinder -silent -all -d "$DOMAIN" -o "$SUBFINDER_OUT"

if [ "$SKIP_AMASS" -eq 0 ] && command -v amass >/dev/null 2>&1; then
    log "Running amass passive enum"
    amass enum -passive -norecursive -d "$DOMAIN" -o "$AMASS_OUT"
else
    : >"$AMASS_OUT"
    log "Skipping amass stage"
fi

sort -u "$SUBFINDER_OUT" "$AMASS_OUT" >"$COMBINED_OUT"
log "Combined subdomains: $(wc -l <"$COMBINED_OUT")"

if [ -n "$RESOLVERS" ]; then
    dnsx -silent -r "$RESOLVERS" -l "$COMBINED_OUT" -o "$RESOLVED_OUT"
else
    dnsx -silent -l "$COMBINED_OUT" -o "$RESOLVED_OUT"
fi

httpx -silent -follow-redirects -tech-detect -title -status-code -l "$RESOLVED_OUT" -o "$HTTPX_OUT"

cat <<EOF
Output directory : $OUTDIR
Subfinder hits   : $(wc -l <"$SUBFINDER_OUT")
Resolved hosts   : $(wc -l <"$RESOLVED_OUT")
Live web services: $(wc -l <"$HTTPX_OUT")
EOF
