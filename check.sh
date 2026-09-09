#!/usr/bin/env bash
# check.sh — report any app whose vendored fond.css has drifted.
#
# Meant to be wired into an app's CI the way check-versions.sh already is, so a
# stale copy fails the build instead of being something to spot by eye. Run
# from this repo it checks every app; run with a path it checks that one, which
# is the form CI uses:
#
#   ./check.sh                     check every app
#   ./check.sh /path/to/zerkalo    check one, exit non-zero if stale

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/style/fond.css"
PROJECTS="$(cd "$HERE/.." && pwd)"

check_one() {
  local dir="$1" name
  name="$(basename "$dir")"
  local dest="$dir/style/fond.css"
  if [[ ! -f "$dest" ]]; then
    printf '  absent %-12s (not using fond-style yet)\n' "$name"
    return 0
  fi
  if cmp -s "$SRC" "$dest"; then
    printf '  ok     %-12s\n' "$name"
    return 0
  fi
  printf '  STALE  %-12s — run fond-style/sync.sh %s\n' "$name" "$name"
  return 1
}

rc=0
if [[ $# -gt 0 ]]; then
  check_one "$1" || rc=1
else
  for app in rubric zerkalo skrizhal iskra Gost kopilka retseptura chered kartoteka/kartoteka-ui-gtk sputnik/sputnik-ui-gtk; do
    [[ -d "$PROJECTS/$app" ]] || continue
    check_one "$PROJECTS/$app" || rc=1
  done
fi

[[ $rc -eq 0 ]] && echo "fond.css is current everywhere it is used."
exit $rc
