#!/usr/bin/env bash
# install-fondwaveslate.sh — install the Fondwave Slate global theme into the
# user's Plasma.
#
# Fondwave Slate keeps Fond's neutral grey surfaces (FondLight/FondDark's own
# background/alternate/neutral-foreground values, copied verbatim) but swaps
# the accent-carrying roles — Decoration, ForegroundActive/Link/Visited/
# Negative/Neutral/Positive, and the whole Selection block — for Fondwave's
# indigo/berry/coral highlights. Reuses Fond's shared desktoptheme, same as
# Fond and Fondwave. See install.sh and install-fondwave.sh for the two it
# sits beside.
#
#   ./install-fondwaveslate.sh            install, and say how to apply it
#   ./install-fondwaveslate.sh --apply    install and apply immediately
#   ./install-fondwaveslate.sh --uninstall

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}"
LNF="io.github.calstfrancis.fondwaveslate"

install_files() {
  echo "installing Fondwave Slate into $DEST"
  install -Dm644 "$HERE/color-schemes/FondwaveSlateLight.colors" "$DEST/color-schemes/FondwaveSlateLight.colors"
  install -Dm644 "$HERE/color-schemes/FondwaveSlateDark.colors"  "$DEST/color-schemes/FondwaveSlateDark.colors"
  echo "  color-schemes/FondwaveSlateLight.colors"
  echo "  color-schemes/FondwaveSlateDark.colors"

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
  echo "removing Fondwave Slate from $DEST"
  rm -f  "$DEST/color-schemes/FondwaveSlateLight.colors" "$DEST/color-schemes/FondwaveSlateDark.colors"
  rm -rf "${DEST:?}/plasma/look-and-feel/$LNF"
  echo "done (plasma/desktoptheme/fond left in place — Fond may still use it)"
}

apply() {
  echo "applying Fondwave Slate to the running session"
  lookandfeeltool --apply "$LNF"
  kwriteconfig6 --file plasmarc --group Theme --key name fond
  echo
  echo "Applied. Some Qt apps only pick up a colour scheme on restart."
  echo "For dark: System Settings → Colors → Fondwave Slate Dark."
}

case "${1:-}" in
  --uninstall) uninstall_files ;;
  --apply)     install_files; apply ;;
  "")
    install_files
    echo
    echo "Installed. Apply it with either:"
    echo "  ./install-fondwaveslate.sh --apply"
    echo "  System Settings → Appearance → Global Theme → Fondwave Slate"
    ;;
  *)
    echo "usage: $0 [--apply|--uninstall]" >&2
    exit 2
    ;;
esac
