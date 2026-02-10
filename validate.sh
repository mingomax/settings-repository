#!/usr/bin/env bash
################################################################################
# Validação Pós-Setup - Verifica se tudo foi instalado corretamente
# Uso: ./validate.sh
################################################################################

set -euo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

check() {
  local name="$1"
  local cmd="$2"
  local optional="${3:-false}"

  echo -n "Verificando $name... "
  
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
    return 0
  else
    if [ "$optional" = "true" ]; then
      echo -e "${YELLOW}⚠${NC} (opcional)"
      ((WARNINGS++))
    else
      echo -e "${RED}✗${NC}"
      ((FAILED++))
    fi
    return 1
  fi
}

check_file() {
  local name="$1"
  local path="$2"
  local optional="${3:-false}"

  echo -n "Verificando $name... "
  
  if [ -e "$path" ]; then
    echo -e "${GREEN}✓${NC} ($path)"
    ((PASSED++))
    return 0
  else
    if [ "$optional" = "true" ]; then
      echo -e "${YELLOW}⚠${NC} (opcional) ($path)"
      ((WARNINGS++))
    else
      echo -e "${RED}✗${NC} ($path)"
      ((FAILED++))
    fi
    return 1
  fi
}

check_var() {
  local name="$1"
  local var="$2"

  echo -n "Verificando variável $name... "
  
  if eval "[ -n \"\${$var:-}\" ]"; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC}"
    ((FAILED++))
    return 1
  fi
}

# Header
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║        Validação Pós-Setup - Dotfiles                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ===== Shell =====
echo -e "${BLUE}🐚 SHELL${NC}"
check "Shell is Zsh" "[ \"\$(basename \$SHELL)\" = 'zsh' ]"
check "Oh-My-Zsh installed" "[ -d ~/.oh-my-zsh ]"
check_file ".zshrc symlinked" "$HOME/.zshrc"
check "Powerlevel10k theme" "[ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]" true
echo ""

# ===== Git =====
echo -e "${BLUE}📦 GIT${NC}"
check "Git installed" "command -v git"
check "Git config exists" "[ -f ~/.gitconfig ]"
check "Git user.name configured" "git config --global user.name | grep -q ."
check "Git user.email configured" "git config --global user.email | grep -q ."
check "Global gitignore" "[ -f ~/.gitignore ]"
check "Global gitattributes" "[ -f ~/.gitattributes ]"
echo ""

# ===== SSH =====
echo -e "${BLUE}🔐 SSH${NC}"
check_file "SSH config directory" "$HOME/.ssh"
check_file "SSH config file" "$HOME/.ssh/config"
check_file "SSH config.d directory" "$HOME/.ssh/config.d"
check_file "SSH keys directory" "$HOME/.ssh/keys"
check_file "SSH helper script" "$HOME/.local/bin/ssh-fix-perms"
check "SSH keys can be listed" "ssh-add -l >/dev/null 2>&1" true
echo ""

# ===== Tools =====
echo -e "${BLUE}🛠️  FERRAMENTAS${NC}"
check "Zsh installed" "command -v zsh"
check "Git installed" "command -v git"
check "direnv installed" "command -v direnv" true
check "fd or fdfind available" "command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1" true
check "ripgrep installed" "command -v rg" true
check "bat/batcat installed" "command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1" true
echo ""

# ===== Environment =====
echo -e "${BLUE}⚙️  AMBIENTE${NC}"
check_var "HOME exists" "HOME"
check "Locale configured" "locale | grep -q LANG"
check "Java installed" "command -v java" true

if [ -n "${JAVA_HOME:-}" ]; then
  echo "JAVA_HOME: $JAVA_HOME"
fi

echo ""

# ===== Aliases =====
echo -e "${BLUE}📝 ALIASES${NC}"
check "Git aliases loaded" "alias | grep -q '^gst='"
check "Docker aliases" "alias | grep -q '^d='" true
check "Work alias" "alias | grep -q '^work='"
check "Personal alias" "alias | grep -q '^personal='"
echo ""

# ===== Dotfiles Structure =====
echo -e "${BLUE}📂 ESTRUTURA DOTFILES${NC}"
check_file "ssh/config" "$HOME/.ssh/config"
check_file "git/gitconfig" "$HOME/.gitconfig"
check_file "zsh/zshrc" "$HOME/.zshrc"
check_file "direnv config" "$HOME/.config/direnv/direnvrc" true
echo ""

# ===== Summary =====
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ Setup validado com sucesso!${NC}"
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS avisos (itens opcionais)${NC}"
  fi
else
  echo -e "${RED}❌ Setup incompleto!${NC}"
  echo -e "${RED}$FAILED itens falharam${NC}"
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS avisos (itens opcionais)${NC}"
  fi
fi

echo ""
echo -e "✅ $PASSED | ❌ $FAILED | ⚠️  $WARNINGS"
echo ""

# Recomendações
if [ $FAILED -gt 0 ]; then
  echo -e "${YELLOW}Recomendações:${NC}"
  if ! check "Shell is Zsh" "[ \"\$(basename \$SHELL)\" = 'zsh' ]" 2>/dev/null; then
    echo "  1. Altere shell para zsh: chsh -s \$(which zsh)"
  fi
  if ! check "Git user.name configured" "git config --global user.name | grep -q ." 2>/dev/null; then
    echo "  2. Configure Git: git config --global user.name 'Seu Nome'"
  fi
  if ! check "Git user.email configured" "git config --global user.email | grep -q ." 2>/dev/null; then
    echo "  3. Configure Git: git config --global user.email 'seu@email.com'"
  fi
  if ! check "SSH keys can be listed" "ssh-add -l >/dev/null 2>&1" 2>/dev/null; then
    echo "  4. Adicione chaves SSH: ssh-add ~/.ssh/keys/id_*"
  fi
  echo ""
  exit 1
fi

exit 0
