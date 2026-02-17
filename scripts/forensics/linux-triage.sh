#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: linux-triage.sh [-o <output_dir>]

Captures:
  - host and user context
  - running processes and network sockets
  - persistence locations, services, and cron jobs
  - recent filesystem activity and privileged binaries
EOF
}

OUTDIR=""

while [ $# -gt 0 ]; do
    case "$1" in
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

OUTDIR="$(make_outdir "linux-triage-$(hostname 2>/dev/null || echo host)" "$OUTDIR")"

collect() {
    local name="$1"
    shift
    {
        printf '# %s\n\n' "$name"
        "$@"
    } >"$OUTDIR/$name.txt" 2>&1 || true
}

collect_shell() {
    local name="$1"
    shift
    {
        printf '# %s\n\n' "$name"
        bash -lc "$*"
    } >"$OUTDIR/$name.txt" 2>&1 || true
}

collect host_overview uname -a
collect_shell os_release 'cat /etc/os-release'
collect_shell identity 'id && whoami && who && w'
collect_shell uptime 'date && uptime && last -a | head -n 40 && lastlog | head -n 40'
collect_shell users 'cat /etc/passwd && printf "\n==== sudoers ====\n" && cat /etc/sudoers'
collect_shell processes 'ps auxf && printf "\n==== top CPU ====\n" && ps aux --sort=-%cpu | head -n 30'
collect_shell proc_network 'ss -tupn && printf "\n==== interfaces ====\n" && ip a && printf "\n==== routes ====\n" && ip r'
collect_shell listening 'lsof -nP -i || netstat -tulpn'
collect_shell persistence 'systemctl list-unit-files --type=service --state=enabled && printf "\n==== rc.local ====\n" && cat /etc/rc.local 2>/dev/null && printf "\n==== ld.so.preload ====\n" && cat /etc/ld.so.preload 2>/dev/null'
collect_shell cron 'cat /etc/crontab 2>/dev/null && printf "\n==== /etc/cron.* ====\n" && find /etc/cron* -maxdepth 2 -type f -print -exec cat {} \\; 2>/dev/null && printf "\n==== user crons ====\n" && for user in $(cut -d: -f1 /etc/passwd); do crontab -u "$user" -l 2>/dev/null | sed "s/^/$user: /"; done'
collect_shell filesystem 'find / -mtime -2 -type f 2>/dev/null | head -n 400 && printf "\n==== SUID ====\n" && find / -perm -4000 -type f 2>/dev/null && printf "\n==== capabilities ====\n" && getcap -r / 2>/dev/null'
collect_shell tmp_space 'find /tmp /var/tmp -maxdepth 3 -type f -printf "%TY-%Tm-%Td %TH:%TM %p\n" 2>/dev/null | sort'
collect_shell auth_logs 'grep -iE "failed|accepted|sudo|session opened|useradd|adduser" /var/log/auth.log /var/log/secure /var/log/syslog /var/log/messages 2>/dev/null | tail -n 400'

cat <<EOF
Output directory: $OUTDIR
Key files:
  - $OUTDIR/processes.txt
  - $OUTDIR/proc_network.txt
  - $OUTDIR/persistence.txt
  - $OUTDIR/cron.txt
EOF
