# QUICK REFERENCE - Dotfiles Setup

Referência rápida para instalar e troubleshoot os dotfiles.

---

## ⚡ Setup em 30 Segundos

```bash
# 1. Clone
git clone https://github.com/mingomax/dotfiles.git ~/Workspace/Personal/dotfiles
cd ~/Workspace/Personal/dotfiles

# 2. Setup
./setup.sh

# 3. Configure Git
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"

# 4. Recarregue shell
exec zsh
```

---

## 📋 Estrutura de Pastas Esperada

```
~/Workspaces/
├── Personal/
│   ├── dotfiles/          ← AQUI
│   └── (seus projetos)
└── Work/
    └── (seus projetos)
```

❌ **NÃO funciona em:**
- `~/Workspaces/` (com 's')
- `~/dotfiles` (home direto)
- Outros paths

✅ **Solução:** Customize com env vars:
```bash
export DOTFILES_DIR="$HOME/seu-path/dotfiles"
./setup.sh
```

---

## 🆘 Troubleshooting Rápido

### ❌ Shell não é Zsh

```bash
chsh -s $(which zsh)
exec zsh
```

### ❌ Git não reconhece profile

```bash
# Verificar
cd ~/Workspace/Personal/seu-projeto
git config user.email  # Deve ser email pessoal

# Se não funcionar
cat ~/.gitconfig | grep includeIf
# Deve ter ${HOME}, não ~
```

### ❌ SSH não funciona

```bash
# Fix perms
~/.local/bin/ssh-fix-perms

# Adicionar chaves
ssh-add ~/.ssh/keys/id_*

# Verificar
ssh-add -l
```

### ❌ Java não detectado

```bash
# Verificar
which java
echo $JAVA_HOME

# Se vazio, instale Java
sudo apt-get install -y default-jdk
exec zsh
```

### ❌ `fd` não existe

```bash
# Ubuntu/Debian usa fdfind
command -v fdfind

# Se não existir, instale
sudo apt-get install -y fd-find
```

---

## ✅ Validar Setup

```bash
./validate.sh
```

Deve mostrar ✓ para tudo (exceto itens opcionais ⚠).

---

## 📚 Documentos

| Documento | Propósito |
|-----------|-----------|
| [README.md](README.md) | Visão geral |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Instalação detalhada |
| [COMPATIBILITY_AUDIT.md](COMPATIBILITY_AUDIT.md) | Análise técnica |
| [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md) | O que mudou |

---

## 🔧 Customizar Paths

Se sua estrutura é diferente:

```bash
export DOTFILES_DIR="$HOME/custom/path/dotfiles"
export WORK_DIR="$HOME/custom/path/work"
export PERSONAL_DIR="$HOME/custom/path/personal"

./setup.sh
```

No `.zshrc`:
Use variáveis que você setou acima.

---

## 🪟 WSL (Windows 11)

```bash
# Em PowerShell (Windows)
wsl --install -d Ubuntu

# No WSL
mkdir -p ~/Workspace/Personal ~/Workspace/Work
git clone https://github.com/mingomax/dotfiles.git ~/Workspace/Personal/dotfiles
cd ~/Workspace/Personal/dotfiles
./setup.sh
```

---

## 🔐 SSH Setup (Importante!)

```bash
# 1. Copiar chaves (com MUITO cuidado!)
cp /path/to/your/keys/id_* ~/.ssh/keys/
chmod 600 ~/.ssh/keys/id_*
chmod 644 ~/.ssh/keys/*.pub

# 2. Fix permissões
~/.local/bin/ssh-fix-perms

# 3. Adicionar ao agent
ssh-add ~/.ssh/keys/id_*

# 4. Verificar
ssh-add -l
ssh -T git@github.com
```

---

## 📝 Git Profiles

### Personalizar para trabalho

Edite `git/work.gitconfig`:
```ini
[user]
  name = Seu Nome
  email = seu.email@trabalho.com
```

Depois de `git init` em `~/Workspace/Work/projeto`:
```bash
git config user.email  # Mostra email de trabalho
```

---

## 🐚 Aliases Comuns

```bash
gst          # git status
ga           # git add -A
gcm "msg"    # git commit -m
gp           # git push
gl           # git pull (rebase)

work         # cd ~/Workspace/Work
personal     # cd ~/Workspace/Personal

d ps         # docker ps
dc up        # docker compose up
k get pods   # kubectl get pods

mvnci        # mvn clean install (sem testes)
```

---

## 🔄 Pós-Setup (Passos Manuais)

- [ ] Oh-My-Zsh: Follow [SETUP_GUIDE.md](SETUP_GUIDE.md#oh-my-zsh)
- [ ] Powerlevel10k: Follow [SETUP_GUIDE.md](SETUP_GUIDE.md#powerlevel10k-theme)
- [ ] Plugins Zsh: Follow [SETUP_GUIDE.md](SETUP_GUIDE.md#zsh-plugins)
- [ ] NVM: Follow [SETUP_GUIDE.md](SETUP_GUIDE.md#nvm-node-version-manager)
- [ ] direnv allow: `direnv allow` em cada project
- [ ] SSH keys: Copiar para `~/.ssh/keys/`

---

## ✨ Verificações Finais

```bash
# 1. Shell
echo $SHELL  # /usr/bin/zsh

# 2. Git
git config --global user.name  # Seu nome

# 3. SSH
ssh-add -l  # Listar chaves

# 4. Aliases
alias | head  # Ver alguns aliases

# 5. Validar tudo
./validate.sh  # Deve passar em tudo
```

---

## 📞 Suporte

- **Issue:** GitHub Issues
- **Docs:** Veja [SETUP_GUIDE.md](SETUP_GUIDE.md) seção Troubleshooting
- **Audit:** Veja [COMPATIBILITY_AUDIT.md](COMPATIBILITY_AUDIT.md) para detalhes

---

**Última atualização:** Feb 9, 2026
