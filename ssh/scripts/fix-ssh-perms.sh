#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="$HOME/.ssh"
CFG="$SSH_DIR/config"
CFGD="$SSH_DIR/config.d"
KEYS="$SSH_DIR/keys"

fix_dir_perms() {
  local dir="$1"
  [ -e "$dir" ] || return 0
  sudo chown -R "$USER:$USER" "$dir" 2>/dev/null || true
  chmod 700 "$dir" 2>/dev/null || true
}

fix_configd_perms() {
  local dir="$1"
  [ -e "$dir" ] || return 0

  # If it's a symlink, fix the target, not the link itself
  if [ -L "$dir" ]; then
    dir="$(readlink -f "$dir")"
  fi

  [ -d "$dir" ] || return 0
  sudo chown -R "$USER:$USER" "$dir" 2>/dev/null || true
  chmod 700 "$dir" 2>/dev/null || true
  chmod 600 "$dir"/*.conf 2>/dev/null || true
}

fix_keys_perms() {
  local dir="$1"
  [ -e "$dir" ] || return 0

  # If it's a symlink, fix the target, not the link itself
  if [ -L "$dir" ]; then
    dir="$(readlink -f "$dir")"
  fi

  [ -d "$dir" ] || return 0
  sudo chown -R "$USER:$USER" "$dir" 2>/dev/null || true
  chmod 700 "$dir" 2>/dev/null || true

  # Private keys
  chmod 600 "$dir"/id_* 2>/dev/null || true
  # Public keys
  chmod 644 "$dir"/*.pub 2>/dev/null || true
}

# Base .ssh
mkdir -p "$SSH_DIR"
fix_dir_perms "$SSH_DIR"

# ~/.ssh/config
if [ -f "$CFG" ]; then
  sudo chown "$USER:$USER" "$CFG" 2>/dev/null || true
  chmod 600 "$CFG" 2>/dev/null || true
fi

# ~/.ssh/config.d (and its target if symlink)
fix_configd_perms "$CFGD"

# ~/.ssh/keys (and its target if symlink)
fix_keys_perms "$KEYS"

# known_hosts can be 644
chmod 644 "$SSH_DIR/known_hosts" "$SSH_DIR/known_hosts2" 2>/dev/null || true

echo "✅ SSH permissions OK"
