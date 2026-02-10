#!/usr/bin/env bash
set -euo pipefail

BOLD="\033[1m"; RESET="\033[0m"
ok(){ echo -e "✅ $*"; }
warn(){ echo -e "⚠️ $*"; }
fail(){ echo -e "❌ $*"; exit 1; }
hdr(){ echo -e "\n${BOLD}$*${RESET}"; }

SSH_DIR="$HOME/.ssh"
CFG="$SSH_DIR/config"
CFGD="$SSH_DIR/config.d"
KEYS="$SSH_DIR/keys"
SOCK="$SSH_DIR/agent.sock"

host_summary() {
  local host="$1"
  echo "— $host"
  ssh -G "$host" 2>/dev/null | awk '
    BEGIN{IGNORECASE=1}
    /^(user|hostname|identitiesonly|identityfile)\s/ {print "  " $0}
  '
}

check_perm_max() {
  local path="$1" max="$2" label="${3:-$1}"
  [ -e "$path" ] || { warn "$label: not found"; return 0; }
  local perm
  perm="$(stat -c %a "$path")"
  if [ "$perm" -gt "$max" ]; then
    warn "$label: permissions are $perm (expected <= $max)"
  else
    ok "$label: permissions $perm"
  fi
}

hdr "1) Base files"
[ -d "$SSH_DIR" ] || fail "~/.ssh not found"
ok "~/.ssh exists"

[ -f "$CFG" ] || fail "~/.ssh/config not found"
ok "~/.ssh/config exists"
grep -qE '^Include\s+~/.ssh/config\.d/\*\.conf' "$CFG" \
  && ok "~/.ssh/config includes config.d/*.conf" \
  || warn "~/.ssh/config does not include ~/.ssh/config.d/*.conf"

[ -d "$CFGD" ] || fail "~/.ssh/config.d not found"
ok "~/.ssh/config.d exists"

hdr "2) Permissions sanity"
check_perm_max "$SSH_DIR" 700 "~/.ssh"

if [ -L "$CFG" ]; then
  TARGET="$(readlink -f "$CFG")"
  ok "~/.ssh/config is a symlink -> $TARGET"
  check_perm_max "$TARGET" 600 "config target"
else
  check_perm_max "$CFG" 600 "~/.ssh/config"
fi

if [ -L "$CFGD" ]; then
  TARGET="$(readlink -f "$CFGD")"
  ok "~/.ssh/config.d is a symlink -> $TARGET"
  check_perm_max "$TARGET" 700 "config.d target"
else
  check_perm_max "$CFGD" 700 "~/.ssh/config.d"
fi


# keys dir is optional, but recommended
if [ -d "$KEYS" ]; then
  check_perm_max "$KEYS" 700 "~/.ssh/keys"
  # check private key perms
  shopt -s nullglob
  for k in "$KEYS"/id_*; do
    if [[ "$k" == *.pub ]]; then
      check_perm_max "$k" 644 "$(basename "$k")"
    else
      check_perm_max "$k" 600 "$(basename "$k")"
    fi
  done
else
  warn "~/.ssh/keys not found (ok if you keep keys elsewhere)"
fi

hdr "3) Agent status"
if [ -S "$SOCK" ]; then
  ok "agent socket exists: $SOCK"
else
  warn "agent socket not found at $SOCK (if you use agent, re-open shell)"
fi

if ssh-add -l >/dev/null 2>&1; then
  ok "ssh-agent reachable"
  ssh-add -l || true
else
  warn "ssh-agent not reachable (ssh-add -l failed)"
fi

hdr "4) SSH config resolution (GitHub)"
host_summary "github.com"

# Validate user git for GitHub
GH_USER="$(ssh -G github.com 2>/dev/null | awk 'BEGIN{IGNORECASE=1} $1=="user"{print $2; exit}')"
if [ "$GH_USER" = "git" ]; then
  ok "github.com user is git"
else
  warn "github.com user is '$GH_USER' (expected 'git')"
fi

GHO_IDONLY="$(ssh -G github.com 2>/dev/null | awk 'BEGIN{IGNORECASE=1} $1=="identitiesonly"{print $2; exit}')"
[ "$GHO_IDONLY" = "yes" ] && ok "IdentitiesOnly is yes for github.com" || warn "IdentitiesOnly is '$GHO_IDONLY'"

hdr "5) Connection tests (optional)"
echo "Running: ssh -T git@github.com (non-interactive, may prompt on first trust)"
ssh -T git@github.com || true

# If you pass aliases as args, test them too:
if [ "${1:-}" != "" ]; then
  for h in "$@"; do
    echo
    echo "Running: ssh -T git@$h"
    ssh -T "git@$h" || true
  done
fi

hdr "Done"
ok "If everything above looks OK, your SSH setup is healthy."
