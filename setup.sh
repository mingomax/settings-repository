#!/usr/bin/env bash
################################################################################
# Dotfiles Setup Script
# Configura novo ambiente Linux com dotfiles
# Uso: ./setup.sh [--no-packages] [--no-symlinks] [--no-git]
################################################################################

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_PACKAGES=false
SKIP_SYMLINKS=false
SKIP_GIT=false

# Detectar ambiente
IS_WSL=false
[ -f /proc/version ] && grep -qi wsl /proc/version && IS_WSL=true

if [ "$IS_WSL" = true ]; then
  log_info "Ambiente WSL detectado"
else
  log_info "Ambiente Linux nativo detectado"
fi

show_help() {
  cat << EOF
Uso: $0 [OPÇÕES]

Opções:
  --no-packages    Não instala pacotes do sistema
  --no-symlinks    Não cria symlinks de configurações
  --no-git         Não configura Git
  -h, --help       Mostra esta ajuda

Exemplo:
  $0                    # Setup completo
  $0 --no-packages      # Setup sem instalar pacotes
EOF
}

# Parse argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-packages) SKIP_PACKAGES=true; shift ;;
    --no-symlinks) SKIP_SYMLINKS=true; shift ;;
    --no-git) SKIP_GIT=true; shift ;;
    -h|--help) show_help; exit 0 ;;
    *) echo "Argumento desconhecido: $1"; show_help; exit 1 ;;
  esac
done

log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

# Detecta distribuição
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# Instala pacotes de sistema
setup_packages() {
  if [ "$SKIP_PACKAGES" = true ]; then
    log_warning "Pulando instalação de pacotes (--no-packages)"
    return 0
  fi

  log_info "Instalando pacotes do sistema..."
  
  DISTRO=$(detect_distro)
  
  case "$DISTRO" in
    ubuntu|debian)
      sudo apt-get update
      sudo apt-get install -y \
        git curl wget build-essential \
        zsh direnv
      
      # Pacotes opcionais (não falha se não conseguir)
      sudo apt-get install -y bat fd-find ripgrep 2>/dev/null || log_warning "Alguns pacotes opcionais não foram instalados"
      
      # Locale pt_BR
      sudo locale-gen pt_BR.UTF-8 2>/dev/null || log_warning "Não foi possível gerar locale pt_BR"
      
      # Code (não code-insiders, que é mais instável)
      if ! command -v code &>/dev/null; then
        log_info "VS Code não detectado. Instalando..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - 2>/dev/null || true
        sudo apt-get install -y code 2>/dev/null || log_warning "VS Code não foi instalado"
      fi
      ;;
    fedora|rhel|centos)
      sudo dnf install -y \
        git curl wget gcc-c++ make redhat-rpm-config \
        zsh direnv
      
      sudo dnf install -y bat fd-find ripgrep 2>/dev/null || log_warning "Alguns pacotes opcionais não foram instalados"
      ;;
    arch)
      sudo pacman -Sy --noconfirm \
        git curl wget base-devel \
        zsh direnv
      
      sudo pacman -Sy --noconfirm bat fd ripgrep 2>/dev/null || log_warning "Alguns pacotes opcionais não foram instalados"
      ;;
    *)
      log_warning "Distribuição desconhecida: $DISTRO"
      log_info "Por favor, instale os pacotes manualmente (git, zsh, direnv requeridos)"
      return 1
      ;;
  esac
  
  log_success "Pacotes instalados"
}

# Cria diretórios necessários
setup_directories() {
  log_info "Criando diretórios..."
  
  mkdir -p "$HOME/.config/git"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.ssh/config.d"
  mkdir -p "$HOME/.ssh/keys"
  
  log_success "Diretórios criados"
}

# Configura Git
setup_git() {
  if [ "$SKIP_GIT" = true ]; then
    log_warning "Pulando configuração de Git (--no-git)"
    return 0
  fi

  log_info "Configurando Git..."
  
  # Detectar editor Git disponível
  GIT_EDITOR=""
  if command -v code-insiders &>/dev/null; then
    GIT_EDITOR="code-insiders -w"
  elif command -v code &>/dev/null; then
    GIT_EDITOR="code -w"
  elif command -v nano &>/dev/null; then
    GIT_EDITOR="nano"
  elif command -v vim &>/dev/null; then
    GIT_EDITOR="vim"
  fi
  
  if [ -n "$GIT_EDITOR" ]; then
    git config --global core.editor "$GIT_EDITOR"
    log_success "Editor Git configurado: $GIT_EDITOR"
  else
    log_warning "Nenhum editor Git encontrado. Configure manualmente: git config --global core.editor <seu-editor>"
  fi
  
  # Cria symlink do gitconfig
  if [ -f "$DOTFILES_DIR/git/gitconfig" ]; then
    ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
    log_success "Gitconfig linkado"
  fi

  # Cria symlink do gitignore global
  if [ -f "$DOTFILES_DIR/git/gitignore" ]; then
    ln -sf "$DOTFILES_DIR/git/gitignore" "$HOME/.gitignore"
    log_success "Global gitignore linkado"
  fi

  # Cria symlink do gitattributes global
  if [ -f "$DOTFILES_DIR/git/gitattributes" ]; then
    ln -sf "$DOTFILES_DIR/git/gitattributes" "$HOME/.gitattributes"
    log_success "Global gitattributes linkado"
  fi
  
  # Cria symlink do allowed_signers
  if [ -f "$DOTFILES_DIR/git/allowed_signers" ]; then
    ln -sf "$DOTFILES_DIR/git/allowed_signers" "$HOME/.config/git/allowed_signers"
    log_success "Allowed signers linkado"
  fi
  
  # Configura user.name e user.email se não existirem
  if ! git config user.name > /dev/null 2>&1; then
    log_warning "Git user.name não configurado. Configure manualmente:"
    log_info "  git config --global user.name 'Seu Nome'"
    log_info "  git config --global user.email 'seu.email@example.com'"
  fi
}

# Configura SSH
setup_ssh() {
  log_info "Configurando SSH..."
  
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  
  # Cria symlink do config
  if [ -f "$DOTFILES_DIR/ssh/config" ]; then
    ln -sf "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    log_success "SSH config linkado"
  fi
  
  # Cria symlink de config.d
  if [ -d "$DOTFILES_DIR/ssh/config.d" ]; then
    for conf in "$DOTFILES_DIR"/ssh/config.d/*.conf; do
      ln -sf "$conf" "$HOME/.ssh/config.d/$(basename "$conf")"
    done
    chmod 600 "$HOME/.ssh/config.d"/*.conf 2>/dev/null || true
    log_success "SSH config.d linkado"
  fi
  
  # Copia scripts e torna-os executáveis
  for script in ssh-agent-start ssh-fix-perms; do
    if [ -f "$DOTFILES_DIR/ssh/$script" ]; then
      cp "$DOTFILES_DIR/ssh/$script" "$HOME/.local/bin/$script"
      chmod +x "$HOME/.local/bin/$script"
    fi
  done
  log_success "Scripts SSH instalados"
}

# Configura Zsh
setup_zsh() {
  log_info "Configurando Zsh..."
  
  # Verifica se Zsh está instalado
  if ! command -v zsh &> /dev/null; then
    log_warning "Zsh não está instalado. Instale com: sudo apt-get install zsh"
    return 1
  fi
  
  # Cria symlink do zshrc
  if [ -f "$DOTFILES_DIR/zsh/zshrc" ]; then
    ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
    log_success "Zshrc linkado"
  fi
  
  # Define Zsh como shell padrão
  if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Definindo Zsh como shell padrão..."
    chsh -s "$(which zsh)"
    log_success "Shell padrão alterado para Zsh"
  else
    log_success "Zsh já é o shell padrão"
  fi
}

# Configura direnv
setup_direnv() {
  log_info "Configurando direnv..."
  
  if ! command -v direnv &> /dev/null; then
    log_warning "direnv não está instalado"
    return 1
  fi
  
  if [ -f "$DOTFILES_DIR/config/direnv/direnvrc" ]; then
    mkdir -p "$HOME/.config/direnv"
    ln -sf "$DOTFILES_DIR/config/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
    log_success "direnv config linkado"
  fi
}

# Configura EditorConfig
setup_editorconfig() {
  log_info "Configurando EditorConfig..."
  
  if [ -f "$DOTFILES_DIR/.editorconfig" ]; then
    ln -sf "$DOTFILES_DIR/.editorconfig" "$HOME/.editorconfig"
    log_success "EditorConfig linkado"
  fi
}

# Configura VS Code Insiders
setup_vscode() {
  log_info "Configurando VS Code Insiders..."
  
  VSCODE_SETTINGS="$HOME/.config/Code - Insiders/User"
  
  if [ -d "$DOTFILES_DIR/vscode" ]; then
    mkdir -p "$VSCODE_SETTINGS"
    
    if [ -f "$DOTFILES_DIR/vscode/settings.json" ]; then
      ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_SETTINGS/settings.json"
      log_success "VS Code settings linkado"
    fi
  fi
}

# Configura PHPStorm
setup_phpstorm() {
  log_info "Configurando PHPStorm..."
  
  PHPSTORM_CONFIG="$HOME/.config/JetBrains/PhpStorm"
  
  if [ -d "$DOTFILES_DIR/phpstorm" ] && [ -d "$PHPSTORM_CONFIG" ]; then
    # Backup das configurações existentes
    if [ ! -d "$PHPSTORM_CONFIG.backup" ]; then
      cp -r "$PHPSTORM_CONFIG" "$PHPSTORM_CONFIG.backup"
      log_warning "Backup de configurações PHPStorm criado: $PHPSTORM_CONFIG.backup"
    fi
    
    log_warning "PHPStorm requer sincronização manual de configurações"
    log_info "Configurações disponíveis em: $DOTFILES_DIR/phpstorm"
  fi
}

# Resumo final
print_summary() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Setup concluído com sucesso!${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "Próximos passos:"
  echo ""
  echo "1. ${YELLOW}Oh My Zsh${NC}"
  echo "   sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  echo ""
  echo "2. ${YELLOW}Powerlevel10k${NC}"
  echo "   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  echo ""
  echo "3. ${YELLOW}Plugins Zsh${NC}"
  echo "   - zsh-autosuggestions"
  echo "   - zsh-syntax-highlighting"
  echo "   - zsh-completions"
  echo ""
  echo "4. ${YELLOW}NVM (Node Version Manager)${NC}"
  echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/<latest-version>/install.sh | bash"
  echo ""
  echo "5. ${YELLOW}SSH Keys${NC}"
  echo "   Copie suas chaves SSH para: $HOME/.ssh/keys/"
  echo "   Depois execute: $HOME/.local/bin/ssh-fix-perms"
  echo ""
  echo "6. ${YELLOW}Shell padrão${NC}"
  echo "   Abra um novo terminal ou execute: exec zsh"
  echo ""
  echo -e "Mais informações: ${BLUE}$DOTFILES_DIR/README.md${NC}"
  echo ""
}

# Main
main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════════════════╗"
  echo "║          Dotfiles Setup - Linux Environment          ║"
  echo "╚═══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
  
  log_info "Caminho dos dotfiles: $DOTFILES_DIR"
  log_info "Home directory: $HOME"
  echo ""
  
  # Setup na ordem correta
  setup_packages
  setup_directories
  setup_git
  setup_ssh
  setup_editorconfig
  setup_direnv
  setup_zsh
  setup_vscode
  setup_phpstorm
  
  print_summary
}

# Executa main
main "$@"
