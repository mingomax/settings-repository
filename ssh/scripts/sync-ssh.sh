#!/usr/bin/env bash
set -euo pipefail

echo "🔗 Linking SSH config from dotfiles..."

rm -f ~/.ssh/config
rm -rf ~/.ssh/config.d

ln -s ~/dotfiles/ssh/config ~/.ssh/config
ln -s ~/dotfiles/ssh/config.d ~/.ssh/config.d

~/dotfiles/scripts/fix-ssh-perms.sh
