#!/usr/bin/env bash
# One-line installer for presenters on macOS and Linux, from the latest GitHub release.
#
#   curl -fsSL https://raw.githubusercontent.com/tschinz/presenters/main/install.sh | bash
#
# macOS: installs presenters.app into /Applications (Apple Silicon only).
# Linux: installs the .deb via dpkg (Debian/Ubuntu). On other distros, build from source.
set -euo pipefail

REPO="tschinz/presenters"
LATEST_DL="https://github.com/$REPO/releases/latest/download"
API="https://api.github.com/repos/$REPO/releases/latest"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
  Darwin)
    if [ "$arch" != "arm64" ]; then
      echo "Only Apple Silicon (arm64) is published; detected '$arch'. Build from source: https://github.com/$REPO#build-from-source" >&2
      exit 1
    fi
    echo "Downloading presenters for macOS (arm64)…"
    curl -fL "$LATEST_DL/presenters-macos-arm64.zip" -o "$tmp/p.zip"
    echo "Installing to /Applications/presenters.app…"
    rm -rf "/Applications/presenters.app"
    unzip -q "$tmp/p.zip" -d /Applications
    xattr -dr com.apple.quarantine "/Applications/presenters.app" 2>/dev/null || true
    echo "✓ Installed. Launch 'presenters' from /Applications or Spotlight."
    ;;
  Linux)
    if ! command -v dpkg >/dev/null 2>&1; then
      echo "The Linux release is a .deb (Debian/Ubuntu); 'dpkg' was not found. Build from source: https://github.com/$REPO#build-from-source" >&2
      exit 1
    fi
    echo "Finding the latest .deb…"
    url="$(curl -fsSL "$API" | grep -o '"browser_download_url": *"[^"]*\.deb"' | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')"
    [ -n "$url" ] || { echo "No .deb asset in the latest release." >&2; exit 1; }
    echo "Downloading $url"
    curl -fL "$url" -o "$tmp/presenters.deb"
    echo "Installing (needs sudo)…"
    sudo dpkg -i "$tmp/presenters.deb" || sudo apt-get -f install -y
    echo "✓ Installed. Launch 'Presenters' from your applications menu."
    ;;
  *)
    echo "Unsupported OS '$os'. Build from source: https://github.com/$REPO#build-from-source" >&2
    exit 1
    ;;
esac
