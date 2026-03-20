#!/bin/bash
# web-fuzz.sh — ffuf wrapper with SecLists paths baked in
# Usage: ./web-fuzz.sh <url> [wordlist_key]
#
# Wordlist keys:
#   dirs      — medium directories (default)
#   dirs-big  — large directories
#   files     — common files
#   api       — API endpoints
#   params    — GET parameter fuzzing (append ?FUZZ to url)
#   vhosts    — virtual host enumeration (set url to base domain)

SECLIST="/mnt/w/security/seckit/wordlists/SecLists"

declare -A LISTS=(
    ["dirs"]="$SECLIST/Discovery/Web-Content/raft-medium-directories.txt"
    ["dirs-big"]="$SECLIST/Discovery/Web-Content/directory-list-2.3-big.txt"
    ["files"]="$SECLIST/Discovery/Web-Content/raft-medium-files.txt"
    ["api"]="$SECLIST/Discovery/Web-Content/api/api-endpoints.txt"
    ["params"]="$SECLIST/Discovery/Web-Content/burp-parameter-names.txt"
    ["vhosts"]="$SECLIST/Discovery/DNS/subdomains-top1million-5000.txt"
)

URL=$1
KEY=${2:-dirs}
WORDLIST=${LISTS[$KEY]}

if [ -z "$URL" ]; then
    echo "Usage: $0 <url> [wordlist_key]"
    echo "Keys: ${!LISTS[@]}"
    exit 1
fi

if [ ! -f "$WORDLIST" ]; then
    echo "[-] Wordlist not found: $WORDLIST"
    echo "    Have you cloned SecLists into seckit/wordlists/SecLists?"
    exit 1
fi

echo "[*] Fuzzing: $URL"
echo "[*] Wordlist: $KEY ($WORDLIST)"
echo "========================================"

ffuf -u "$URL/FUZZ" \
     -w "$WORDLIST" \
     -mc 200,201,204,301,302,307,401,403 \
     -t 50 \
     -c \
     -v
