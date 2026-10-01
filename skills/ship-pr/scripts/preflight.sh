#!/usr/bin/env bash
# Checks what ship-pr needs. Exit 0: all required tools present. Exit 1: something required is missing.
# Usage: bash preflight.sh [--ui]   (--ui also requires the browser-evidence tools)

ui=0; [ "${1:-}" = "--ui" ] && ui=1
fail=0

os="$(uname -s)"
case "$os" in
  Darwin) pm="brew install" ;;
  Linux)  if command -v apt-get >/dev/null; then pm="sudo apt-get install -y"
          elif command -v dnf >/dev/null; then pm="sudo dnf install -y"
          elif command -v pacman >/dev/null; then pm="sudo pacman -S --noconfirm"
          else pm="<your package manager> install"; fi ;;
  MINGW*|MSYS*|CYGWIN*) pm="winget install" ;;
  *) pm="<your package manager> install" ;;
esac

ok()   { printf 'ok       %s\n' "$1"; }
miss() { printf 'MISSING  %s\n         fix: %s\n' "$1" "$2"; fail=1; }
warn() { printf 'warn     %s\n         fix: %s\n' "$1" "$2"; }

# version_ge A B: true when A >= B
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

if command -v git >/dev/null; then
  v="$(git --version | awk '{print $3}')"
  if version_ge "$v" 2.31; then ok "git $v"; else miss "git $v (need 2.31+)" "$pm git"; fi
else
  miss "git" "$pm git"
fi

remote="$(git remote get-url origin 2>/dev/null || true)"
case "$remote" in
  *github*)
    if command -v gh >/dev/null; then
      v="$(gh --version | head -1 | awk '{print $3}')"
      if version_ge "$v" 2.99.0; then ok "gh $v"
      else miss "gh $v (need 2.99.0+ to attach screenshots and video)" "https://github.com/cli/cli#installation"; fi
      if gh auth status >/dev/null 2>&1; then ok "gh logged in"; else miss "gh not logged in" "gh auth login"; fi
    else
      miss "gh" "https://github.com/cli/cli#installation"
    fi ;;
  *gitlab*)
    if command -v glab >/dev/null; then ok "glab"; else miss "glab" "https://gitlab.com/gitlab-org/cli#installation"; fi ;;
  "")
    warn "no 'origin' remote: the PR cannot be opened" "git remote add origin <url>" ;;
  *)
    warn "forge for $remote not recognised: open the PR by hand or with its CLI" "see references/evidence.md" ;;
esac

ui_check() { if [ "$ui" = 1 ]; then miss "$@"; else warn "$@"; fi; }

if command -v node >/dev/null; then ok "node $(node --version)"; else ui_check "node (for Playwright)" "https://nodejs.org or $pm nodejs"; fi

if command -v npx >/dev/null && npx --no-install playwright --version >/dev/null 2>&1; then
  ok "playwright $(npx --no-install playwright --version 2>/dev/null | awk '{print $2}')"
else
  ui_check "playwright" "npm install -D @playwright/test && npx playwright install chromium"
fi

if command -v ffmpeg >/dev/null; then ok "ffmpeg"; else ui_check "ffmpeg (GIF conversion)" "$pm ffmpeg"; fi

if [ "$fail" = 1 ]; then echo "preflight: FAILED (exit 1)"; else echo "preflight: passed (exit 0)"; fi
exit "$fail"
