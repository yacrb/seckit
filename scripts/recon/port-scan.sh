#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: port-scan.sh -t <host|cidr> [-o <output_dir>] [--top-ports <count>] [--min-rate <rate>] [--skip-ping]

Stages:
  1. ICMP / ARP host discovery
  2. Top ports service scan
  3. Full TCP port sweep
  4. Nmap vuln scripts against discovered ports
EOF
}

TARGET=""
OUTDIR=""
TOP_PORTS=1000
MIN_RATE=2000
SKIP_PING=0

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        --top-ports)
            TOP_PORTS="$2"
            shift 2
            ;;
        --min-rate)
            MIN_RATE="$2"
            shift 2
            ;;
        --skip-ping)
            SKIP_PING=1
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

[ -n "$TARGET" ] || { usage; exit 1; }
need_cmd nmap

extract_ports() {
    local gnmap_file="$1"
    awk -F'Ports: ' '/Ports: / {print $2}' "$gnmap_file" \
        | cut -d' ' -f1 \
        | tr ',' '\n' \
        | cut -d'/' -f1 \
        | sort -nu \
        | paste -sd, -
}

scan_host() {
    local host="$1"
    local host_dir="$OUTDIR/$host"
    local full_ports

    mkdir -p "$host_dir"
    log "Top port scan: $host"
    nmap -Pn -T4 -sC -sV --top-ports "$TOP_PORTS" -oA "$host_dir/top-ports" "$host"

    log "Full TCP sweep: $host"
    nmap -Pn -T4 -p- --min-rate "$MIN_RATE" -oA "$host_dir/full" "$host"

    full_ports="$(extract_ports "$host_dir/full.gnmap")"
    if [ -z "$full_ports" ]; then
        warn "No open TCP ports found on $host"
        return 0
    fi

    log "Vuln scripts on $host ($full_ports)"
    nmap -Pn -T4 -sV -sC --script vuln -p "$full_ports" -oA "$host_dir/vuln" "$host"
}

OUTDIR="$(make_outdir "port-scan-$(printf '%s' "$TARGET" | tr '/.' '--')" "$OUTDIR")"
HOSTS_FILE="$OUTDIR/live-hosts.txt"

if [ "$SKIP_PING" -eq 1 ]; then
    printf '%s\n' "$TARGET" >"$HOSTS_FILE"
else
    log "Host discovery against $TARGET"
    nmap -sn -oG "$OUTDIR/ping-sweep.gnmap" "$TARGET"
    awk '/Up$/{print $2}' "$OUTDIR/ping-sweep.gnmap" >"$HOSTS_FILE"
fi

if [ ! -s "$HOSTS_FILE" ]; then
    die "No live hosts discovered."
fi

while read -r host; do
    [ -n "$host" ] || continue
    scan_host "$host"
done <"$HOSTS_FILE"

cat <<EOF
Output directory : $OUTDIR
Live hosts       : $(wc -l <"$HOSTS_FILE")
EOF
