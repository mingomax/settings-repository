#!/usr/bin/env bash
set -euo pipefail

# ========= Configuração Inicial =========
# Detectar DOTFILES_DIR (compatível com diferentes estruturas)
if [ -z "${DOTFILES_DIR:-}" ]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Detectar ambiente
IS_WSL=false
[ -f /proc/version ] && grep -qi wsl /proc/version && IS_WSL=true

say() { printf "\n\033[1m%s\033[0m\n" "$*"; }
ok()  { printf "✅ %s\n" "$*"; }
warn(){ printf "⚠️ %s\n" "$*"; }

require_dir() {
  if [ ! -d "$1" ]; then
    echo "❌ Required directory not found: $1"
    exit 1
  fi
}

symlink_force() {
  local src="$1"
  local dst="$2"
  rm -f "$dst"
  ln -s "$src" "$dst"
}

say "1) Validating dotfiles repo"
require_dir "$DOTFILES_DIR"
require_dir "$DOTFILES_DIR/ssh"
require_dir "$DOTFILES_DIR/ssh/config.d"
require_dir "$DOTFILES_DIR/ssh/scripts"
require_dir "$DOTFILES_DIR/git"
require_dir "$DOTFILES_DIR/zsh"
ok "Dotfiles structure looks good: $DOTFILES_DIR"

say "2) Installing base packages"
sudo apt update -y
sudo apt install -y \
  git curl unzip zip ca-certificates build-essential \
  zsh direnv
ok "Base packages installed"

say "3) Ensuring Zsh is default shell (optional)"
if command -v zsh >/dev/null 2>&1; then
  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    warn "Changing default shell to zsh (may ask password)"
    chsh -s "$(command -v zsh)" || warn "Could not change shell automatically (you can run: chsh -s $(command -v zsh))"
  fi
  ok "Zsh available"
fi

say "4) Installing Oh My Zsh (if not installed)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

say "5) Linking dotfiles"
# gitconfig
if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
  symlink_force "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  ok "Linked ~/.gitconfig"
else
  warn "Missing: $DOTFILES_DIR/git/.gitconfig"
fi

# zshrc
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  symlink_force "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  ok "Linked ~/.zshrc"
else
  warn "Missing: $DOTFILES_DIR/zsh/.zshrc"
fi

say "6) Ensuring SSH config files exist in dotfiles"
# Ensure dotfiles/ssh/config exists (fallback)
if [ ! -f "$DOTFILES_DIR/ssh/config" ]; then
  warn "Missing: $DOTFILES_DIR/ssh/config — creating minimal Include file"
  printf "Include ~/.ssh/config.d/*.conf\n" > "$DOTFILES_DIR/ssh/config"
  chmod 600 "$DOTFILES_DIR/ssh/config"
fi

say "7) Linking SSH config to runtime"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

symlink_force "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
rm -rf "$HOME/.ssh/config.d"
ln -s "$DOTFILES_DIR/ssh/config.d" "$HOME/.ssh/config.d"
mkdir -p "$HOME/.ssh/keys"
chmod 700 "$HOME/.ssh/keys"
ok "Linked ~/.ssh/config and ~/.ssh/config.d"

say "8) Installing helper scripts (local bin links)"
mkdir -p "$HOME/.local/bin"

# Link fix script from repo (single source of truth)
symlink_force "$DOTFILES_DIR/ssh/scripts/fix-ssh-perms.sh" "$HOME/.local/bin/ssh-fix-perms"
chmod +x "$HOME/.local/bin/ssh-fix-perms"
ok "Linked ~/.local/bin/ssh-fix-perms"

# ssh-agent-start (local runtime script)
cat > "$HOME/.local/bin/ssh-agent-start" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SOCK="$HOME/.ssh/agent.sock"
ENVFILE="$HOME/.ssh/agent.env"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

start_agent() {
  eval "$(ssh-agent -a "$SOCK")" >/dev/null
  {
    echo "SSH_AUTH_SOCK=$SOCK"
    echo "SSH_AGENT_PID=$SSH_AGENT_PID"
  } > "$ENVFILE"
  chmod 600 "$ENVFILE"
}

# Load previous env if present
if [ -f "$ENVFILE" ]; then
  # shellcheck disable=SC1090
  source "$ENVFILE" >/dev/null 2>&1 || true
fi

export SSH_AUTH_SOCK="$SOCK"

# If socket exists but agent is dead, clean it
if [ -S "$SOCK" ] && ! ssh-add -l >/dev/null 2>&1; then
  rm -f "$SOCK" "$ENVFILE" 2>/dev/null || true
fi

# Start agent if needed
if [ ! -S "$SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
  start_agent
fi

add_key_if_missing() {
  local key="$1"
  [ -f "$key" ] || return 0
  local fp
  fp="$(ssh-keygen -lf "$key" | awk '{print $2}')"
  if ssh-add -l 2>/dev/null | grep -q "$fp"; then
    return 0
  fi
  ssh-add "$key" </dev/tty
}

# Adjust key filenames to your real ones:
add_key_if_missing "$HOME/.ssh/keys/id_ed25519_mingomax_github"
add_key_if_missing "$HOME/.ssh/keys/id_ed25519_ciandt"
add_key_if_missing "$HOME/.ssh/keys/id_ed25519_mingomax_bitbucket"

echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
echo "export SSH_AGENT_PID=${SSH_AGENT_PID:-}"
EOF
chmod +x "$HOME/.local/bin/ssh-agent-start"
ok "Installed ~/.local/bin/ssh-agent-start"

say "9) Ensuring direnv hook is present in ~/.zshrc (idempotent)"
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q 'direnv hook zsh' "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# direnv' >> "$HOME/.zshrc"
    echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
    ok "Added direnv hook to ~/.zshrc"
  else
    ok "direnv hook already present"
  fi
else
  warn "~/.zshrc not found; cannot add direnv hook"
fi

say "10) Ensuring ssh-agent is loaded for interactive shells"
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q 'ssh-agent-start' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" <<'EOF'

# SSH Agent (WSL): only in interactive shells
case $- in
  *i*)
    if [ -x "$HOME/.local/bin/ssh-agent-start" ]; then
      eval "$("$HOME/.local/bin/ssh-agent-start")"
    fi
  ;;
esac
EOF
    ok "Added ssh-agent-start to ~/.zshrc"
  else
    ok "ssh-agent-start already referenced in ~/.zshrc"
  fi
fi

say "11) Creating Workspaces folders + direnv profiles (optional but recommended)"
mkdir -p "$HOME/Workspaces/Work" "$HOME/Workspaces/Personal"
ok "Created ~/Workspaces/Work and ~/Workspaces/Personal"

if [ ! -f "$HOME/Workspaces/Personal/.envrc" ]; then
  cat > "$HOME/Workspaces/Personal/.envrc" <<'EOF'
export GIT_PROFILE=personal
export GIT_AUTHOR_NAME="Domingos Teruel"
export GIT_AUTHOR_EMAIL="mingomax@dteruel.net.br"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
echo "🟢 direnv: PERSONAL profile activated"
EOF
  ok "Created ~/Workspaces/Personal/.envrc"
else
  ok "Personal .envrc already exists"
fi

if [ ! -f "$HOME/Workspaces/Work/.envrc" ]; then
  cat > "$HOME/Workspaces/Work/.envrc" <<'EOF'
export GIT_PROFILE=work
export GIT_AUTHOR_NAME="Domingos Teruel"
export GIT_AUTHOR_EMAIL="domingost@ciandt.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
echo "🔵 direnv: WORK profile activated"
EOF
  ok "Created ~/Workspaces/Work/.envrc"
else
  ok "Work .envrc already exists"
fi

say "12) Fixing SSH permissions (targets real dirs, not symlinks)"
chmod 700 "$DOTFILES_DIR/ssh/config.d" 2>/dev/null || true
chmod 600 "$DOTFILES_DIR/ssh/config.d"/*.conf 2>/dev/null || true
"$HOME/.local/bin/ssh-fix-perms" || true

say "13) Next steps"
cat <<'EOF'
✅ Bootstrap complete.

Manual steps you still need (by design):
1) Place your PRIVATE SSH keys under: ~/.ssh/keys/
2) Ensure public keys exist: ~/.ssh/keys/*.pub
3) Reload shell: exec zsh
4) Approve direnv for each profile:
   cd ~/Workspaces/Personal && direnv allow
   cd ~/Workspaces/Work && direnv allow
5) Validate:
   ssh-add -l
   ssh -T git@github.com
EOF
