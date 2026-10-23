#!/bin/bash
# steg-check.sh — runs common steg tools against a file automatically
# Usage: ./steg-check.sh <file>

if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE=$1
echo "========================================"
echo "[*] Target: $FILE"
echo "========================================"

echo -e "\n[+] file"
file "$FILE"

echo -e "\n[+] exiftool"
exiftool "$FILE" 2>/dev/null || echo "exiftool not found"

echo -e "\n[+] strings (grep flag-like patterns)"
strings "$FILE" | grep -iE "(flag|ctf|htb|thm|\{|\})" 2>/dev/null

echo -e "\n[+] binwalk"
binwalk "$FILE" 2>/dev/null || echo "binwalk not found"

echo -e "\n[+] steghide (no password)"
steghide extract -sf "$FILE" -p "" 2>/dev/null || echo "steghide: no embedded data or not applicable"

echo -e "\n[+] zsteg (PNG/BMP)"
zsteg "$FILE" 2>/dev/null || echo "zsteg not found or not applicable"

echo -e "\n[+] stegoveritas"
stegoveritas "$FILE" 2>/dev/null || echo "stegoveritas not found"

echo -e "\n[+] foremost"
foremost -i "$FILE" -o ./foremost-out 2>/dev/null && echo "foremost output in ./foremost-out" || echo "foremost not found"

echo -e "\n[*] Done."
