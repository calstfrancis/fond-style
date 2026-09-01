#!/usr/bin/env bash
# install-fondwave.sh — install the Fondwave global theme into the user's Plasma.
#
# Fondwave reuses Fond's desktoptheme (it ships no colours file, so it just
# follows whichever scheme is active) and pairs it with Fondwave.colors, a
# dusk palette pulled from the Carmine Cloud keycap set. See install.sh for
# the neutral Fond Light/Dark pair this sits beside.
#
#   ./install-fondwave.sh            install, and say how to apply it
#   ./install-fondwave.sh --apply    install and apply immediately
#   ./install-fondwave.sh --uninstall

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}"
LNF="io.github.calstfrancis.fondwave"

install_files() {
  echo "installing Fondwave into $DEST"
  install -Dm644 "$HERE/color-schemes/Fondwave.colors" "$DEST/color-schemes/Fondwave.colors"
  echo "  color-schemes/Fondwave.colors"

  rm -rf "$DEST/plasma/desktoptheme/fond"
  mkdir -p "$DEST/plasma/desktoptheme"
  cp -r "$HERE/desktoptheme/fond" "$DEST/plasma/desktoptheme/fond"
  echo "  plasma/desktoptheme/fond (shared with Fond)"

  rm -rf "${DEST:?}/plasma/look-and-feel/$LNF"
  mkdir -p "$DEST/plasma/look-and-feel"
  cp -r "$HERE/look-and-feel/$LNF" "$DEST/plasma/look-and-feel/$LNF"
  echo "  plasma/look-and-feel/$LNF"
}

uninstall_files() {
  echo "removing Fondwave from $DEST"
  rm -f  "$DEST/color-schemes/Fondwave.colors"
  rm -rf "${DEST:?}/plasma/look-and-feel/$LNF"
  echo "done (plasma/desktoptheme/fond left in place — Fond may still use it)"
}

apply() {
  echo "applying Fondwave to the running session"
  lookandfeeltool --apply "$LNF"
  kwriteconfig6 --file plasmarc --group Theme --key name fond
  echo
  echo "Applied. Some Qt apps only pick up a colour scheme on restart."
}

case "${1:-}" in
  --uninstall) uninstall_files ;;
  --apply)     install_files; apply ;;
  "")
    install_files
    echo
    echo "Installed. Apply it with either:"
    echo "  ./install-fondwave.sh --apply"
    echo "  System Settings → Appearance → Global Theme → Fondwave"
    ;;
  *)
    echo "usage: $0 [--apply|--uninstall]" >&2
    exit 2
    ;;
esac
