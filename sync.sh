#!/usr/bin/env bash
# sync.sh — push the canonical fond.css out to each app that uses it.
#
# Each app is built as its own flatpak from its own git repository, so the
# stylesheet has to be committed inside that repository rather than pulled in
# as a dependency. This copies it; committing is left to you, in each app, so
# the change lands with a message that says what it changed.
#
#   ./sync.sh            copy to every app listed below
#   ./sync.sh zerkalo    copy to one app

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/style/fond.css"
PROJECTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

APPS=(rubric zerkalo skrizhal iskra Gost kopilka retseptura chered kartoteka/kartoteka-ui-gtk sputnik/sputnik-ui-gtk)

[[ $# -gt 0 ]] && APPS=("$@")

for app in "${APPS[@]}"; do
  dir="$PROJECTS/$app"
  if [[ ! -d "$dir" ]]; then
    printf '  skip   %-12s (no such directory)\n' "$app"
    continue
  fi
  dest="$dir/style/fond.css"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]] && cmp -s "$SRC" "$dest"; then
    printf '  same   %-12s\n' "$app"
  else
    cp "$SRC" "$dest"
    printf '  copied %-12s -> %s\n' "$app" "${dest#"$PROJECTS"/}"
  fi
done
