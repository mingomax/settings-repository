#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y zsh git curl wget unzip fzf ripgrep fd-find bat direnv zoxide fonts-firacode fonts-cascadia-code fonts-droid-fallback git-delta

# batcat -> bat
sudo update-alternatives --install /usr/bin/bat bat /usr/bin/batcat 10 || true

# Oh My Zsh + Powerlevel10k (se não existir)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# MesloLGS NF (recomendada p/ p10k)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
for f in Regular Bold Italic "Bold Italic"; do
  wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$f.ttf -O "MesloLGS NF $f.ttf"
done
fc-cache -fv

# Vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Done. Now run: stow -v git zsh terminator vim vscode"

