#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
    cat <<'EOF'
Usage: privesc-check.sh [-o <output_dir>] [--skip-linpeas]

Runs:
  - linpeas (if PEASS-ng is available)
  - sudo / SUID / capabilities / writable path checks
  - docker, lxd, and kernel quick checks
EOF
}

OUTDIR=""
SKIP_LINPEAS=0
LINPEAS_PATH="$SECKIT_ROOT/tools/post/PEASS-ng/linPEAS/linpeas.sh"

while [ $# -gt 0 ]; do
    case "$1" in
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        --skip-linpeas)
            SKIP_LINPEAS=1
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

OUTDIR="$(make_outdir "privesc-check" "$OUTDIR")"

capture() {
    local name="$1"
    shift
    {
        printf '# %s\n\n' "$name"
        bash -lc "$*"
    } >"$OUTDIR/$name.txt" 2>&1 || true
}

if [ "$SKIP_LINPEAS" -eq 0 ] && [ -f "$LINPEAS_PATH" ]; then
    log "Running linpeas"
    bash "$LINPEAS_PATH" -a >"$OUTDIR/linpeas.txt" 2>&1 || true
else
    warn "Skipping linpeas"
fi

capture identity 'id && groups && uname -a && cat /etc/os-release'
capture sudo 'sudo -n -l 2>&1 || sudo -l 2>&1'
capture suid 'find / -perm -4000 -type f 2>/dev/null'
capture capabilities 'getcap -r / 2>/dev/null'
capture writable 'find / -writable -type d 2>/dev/null | grep -vE "^/(proc|sys|dev|run)" | head -n 400'
capture services 'systemctl list-unit-files --type=service --state=enabled 2>/dev/null && printf "\n==== timers ====\n" && systemctl list-timers --all 2>/dev/null'
capture containers 'getent group docker lxd libvirt 2>/dev/null && printf "\n==== socket perms ====\n" && ls -l /var/run/docker.sock /run/docker.sock 2>/dev/null'
capture kernel 'sysctl kernel.unprivileged_userns_clone 2>/dev/null && cat /proc/version && dpkg -l 2>/dev/null | grep linux-image'
capture manual_summary 'printf "UID 0 accounts:\n"; awk -F: '"'"'$3 == 0 {print $1}'"'"' /etc/passwd; printf "\nCron locations:\n"; find /etc/cron* -maxdepth 2 -type f 2>/dev/null; printf "\nInteresting mounts:\n"; mount | grep -E "nosuid|noexec|overlay"'

if [ -f "$OUTDIR/linpeas.txt" ]; then
    grep -Ei 'sudo|capab|docker|lxd|suid|writable|cron|kernel|password|credential' "$OUTDIR/linpeas.txt" >"$OUTDIR/linpeas-highlights.txt" 2>/dev/null || true
fi

cat <<EOF
Output directory: $OUTDIR
Review first:
  - $OUTDIR/sudo.txt
  - $OUTDIR/suid.txt
  - $OUTDIR/capabilities.txt
  - $OUTDIR/linpeas-highlights.txt
EOF
