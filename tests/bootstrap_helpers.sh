#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=bootstrap.sh
source "$ROOT/bootstrap.sh"
TASK_TMP="$(mktemp -d)"
trap 'rm -rf "$TASK_TMP"' EXIT
BIN_DIR="$TASK_TMP/bin"
mkdir -p "$BIN_DIR"

# Test a real generated launcher without installing or invoking security tools.
TARGET="$TASK_TMP/tool with spaces and \$(touch unexpected)"
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$@"\n' >"$TARGET"
safe_wrapper example example bash "$TARGET"
[ "$("$BIN_DIR/example" 'literal $value' 'with spaces')" = $'literal $value\nwith spaces' ]
[ ! -e unexpected ]

# A user's regular launcher or symlink must survive bootstrap.
printf 'user-managed\n' >"$BIN_DIR/custom"
safe_wrapper custom custom bash "$TARGET"
[ "$(cat "$BIN_DIR/custom")" = 'user-managed' ]
ln -s "$BIN_DIR/custom" "$BIN_DIR/custom-link"
safe_wrapper custom-link custom-link bash "$TARGET"
[ "$(readlink "$BIN_DIR/custom-link")" = "$BIN_DIR/custom" ]

safe_symlink example-link "$TARGET" "$BIN_DIR/example-link"
safe_symlink example-link "$TARGET" "$BIN_DIR/example-link"
[ "$(readlink "$BIN_DIR/example-link")" = "$TARGET" ]
printf 'PASS: literal launcher paths/arguments, existing file and symlink preservation, repeatable links.\n'
