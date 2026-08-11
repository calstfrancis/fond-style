#!/usr/bin/env bash
# install.sh — install the Fond desktop theme into the user's Plasma.
#
# Everything goes under ~/.local/share, so nothing here needs root and nothing
# touches the system Breeze it sits beside. Run it again after editing the
# theme; it overwrites in place.
#
#   ./install.sh            install, and say how to apply it
#   ./install.sh --apply    install and apply immediately
#   ./install.sh --uninstall
#
# --apply rewrites the live colour scheme, desktop theme and decoration. That
# is a visible change to the running session, not a file drop, which is why it
# is not the default.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}"
LNF="io.github.calstfrancis.fond"

install_files() {
  echo "installing Fond into $DEST"
  install -Dm644 "$HERE/color-schemes/FondLight.colors" "$DEST/color-schemes/FondLight.colors"
  install -Dm644 "$HERE/color-schemes/FondDark.colors"  "$DEST/color-schemes/FondDark.colors"
  echo "  color-schemes/FondLight.colors"
  echo "  color-schemes/FondDark.colors"

  rm -rf "$DEST/plasma/desktoptheme/fond"
  mkdir -p "$DEST/plasma/desktoptheme"
  cp -r "$HERE/desktoptheme/fond" "$DEST/plasma/desktoptheme/fond"
  echo "  plasma/desktoptheme/fond"

  rm -rf "${DEST:?}/plasma/look-and-feel/$LNF"
  mkdir -p "$DEST/plasma/look-and-feel"
  cp -r "$HERE/look-and-feel/$LNF" "$DEST/plasma/look-and-feel/$LNF"
  echo "  plasma/look-and-feel/$LNF"
}

uninstall_files() {
  echo "removing Fond from $DEST"
  rm -f  "$DEST/color-schemes/FondLight.colors" "$DEST/color-schemes/FondDark.colors"
  rm -rf "$DEST/plasma/desktoptheme/fond"
  rm -rf "${DEST:?}/plasma/look-and-feel/$LNF"
  echo "done — pick another theme in System Settings if Fond is still applied"
}

apply() {
  echo "applying Fond to the running session"
  lookandfeeltool --apply "$LNF"
  # lookandfeeltool does not always reload the desktop theme in a live session.
  kwriteconfig6 --file plasmarc --group Theme --key name fond
  echo
  echo "Applied. Some Qt apps only pick up a colour scheme on restart."
  echo "For dark: System Settings → Colors → Fond Dark."
}

case "${1:-}" in
  --uninstall) uninstall_files ;;
  --apply)     install_files; apply ;;
  "")
    install_files
    echo
    echo "Installed. Apply it with either:"
    echo "  ./install.sh --apply"
    echo "  System Settings → Appearance → Global Theme → Fond"
    ;;
  *)
    echo "usage: $0 [--apply|--uninstall]" >&2
    exit 2
    ;;
esac
