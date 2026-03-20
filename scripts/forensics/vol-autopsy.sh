#!/bin/bash
# vol-autopsy.sh — first-pass Volatility3 triage on a memory dump
# Usage: ./vol-autopsy.sh <dump.mem>

if [ -z "$1" ]; then
    echo "Usage: $0 <memory_dump>"
    exit 1
fi

DUMP=$1
OUT=./vol-output-$(date +%Y%m%d-%H%M%S)
mkdir -p $OUT

echo "[*] Starting Volatility triage on: $DUMP"
echo "[*] Output dir: $OUT"

plugins=(
    "windows.pstree"
    "windows.cmdline"
    "windows.netscan"
    "windows.netstat"
    "windows.malfind"
    "windows.dlllist"
    "windows.filescan"
    "windows.registry.hivelist"
    "windows.hashdump"
)

for plugin in "${plugins[@]}"; do
    outfile="$OUT/${plugin//\./_}.txt"
    echo "[+] Running $plugin..."
    vol -f "$DUMP" $plugin > "$outfile" 2>&1
done

echo "[*] Done. Results in $OUT/"
echo "[*] Quick summary:"
echo "    Processes : $(grep -c '^\*' $OUT/windows_pstree.txt 2>/dev/null || echo 'n/a')"
echo "    Network   : $(wc -l < $OUT/windows_netscan.txt 2>/dev/null || echo 'n/a') connections"
echo "    Malfind   : $(grep -c 'Process:' $OUT/windows_malfind.txt 2>/dev/null || echo 'n/a') hits"
