#!/usr/bin/env bash
set -euo pipefail

DROPBOX_SSH="/mnt/c/Users/mingo/Dropbox/ssh_files/ssh"
SSH_DIR="$HOME/.ssh"
BACKUP_DIR="$HOME/.backup_ssh/$(date +%Y%m%d-%H%M%S)"

echo "🔐 Syncing SSH config from Dropbox..."
echo "📁 Source: $DROPBOX_SSH"
echo "📁 Target: $SSH_DIR"

mkdir -p "$BACKUP_DIR"
[ -d "$SSH_DIR" ] && cp -a "$SSH_DIR/." "$BACKUP_DIR/" 2>/dev/null || true

rm -rf "$SSH_DIR"
mkdir -p "$SSH_DIR"/{config.d,keys}

cp -a "$DROPBOX_SSH/config" "$SSH_DIR/config"
cp -a "$DROPBOX_SSH/config.d/." "$SSH_DIR/config.d/"
cp -a "$DROPBOX_SSH/keys/." "$SSH_DIR/keys/"

sudo chown -R "$USER:$USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 700 "$SSH_DIR/config.d" "$SSH_DIR/keys"
chmod 600 "$SSH_DIR/config" "$SSH_DIR/config.d"/*.conf
chmod 600 "$SSH_DIR/keys"/id_* 2>/dev/null || true
chmod 644 "$SSH_DIR/keys"/*.pub 2>/dev/null || true
chmod 644 "$SSH_DIR/known_hosts" 2>/dev/null || true

echo "✅ SSH sync completed successfully."
