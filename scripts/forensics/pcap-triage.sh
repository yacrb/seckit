#!/bin/bash
# pcap-triage.sh — first-pass analysis on a PCAP file
# Usage: ./pcap-triage.sh <file.pcap>

if [ -z "$1" ]; then
    echo "Usage: $0 <file.pcap>"
    exit 1
fi

PCAP=$1
OUT=./pcap-triage-$(date +%Y%m%d-%H%M%S)
mkdir -p $OUT

echo "[*] PCAP: $PCAP"
echo "[*] Output: $OUT"
echo "========================================"

echo -e "\n[+] File info"
capinfos "$PCAP" 2>/dev/null | tee $OUT/capinfos.txt

echo -e "\n[+] Unique IPs (src + dst)"
tshark -r "$PCAP" -T fields -e ip.src -e ip.dst 2>/dev/null | tr '\t' '\n' | sort -u | tee $OUT/unique-ips.txt

echo -e "\n[+] Protocol hierarchy"
tshark -r "$PCAP" -q -z io,phs 2>/dev/null | tee $OUT/protocols.txt

echo -e "\n[+] HTTP requests"
tshark -r "$PCAP" -Y http.request -T fields \
    -e ip.src -e ip.dst -e http.request.method -e http.request.uri \
    2>/dev/null | tee $OUT/http-requests.txt

echo -e "\n[+] DNS queries"
tshark -r "$PCAP" -Y dns.flags.response==0 -T fields \
    -e ip.src -e dns.qry.name \
    2>/dev/null | sort -u | tee $OUT/dns-queries.txt

echo -e "\n[+] Credentials (FTP/HTTP basic/Telnet)"
tshark -r "$PCAP" -Y "ftp.request.command==USER or ftp.request.command==PASS or http.authorization" \
    -T fields -e ip.src -e ftp.request.arg -e http.authorization \
    2>/dev/null | tee $OUT/credentials.txt

echo -e "\n[+] Extracting HTTP objects..."
mkdir -p $OUT/http-objects
tshark -r "$PCAP" --export-objects http,$OUT/http-objects 2>/dev/null
echo "    Objects saved to $OUT/http-objects/"

echo -e "\n[*] Done. Review $OUT/"
