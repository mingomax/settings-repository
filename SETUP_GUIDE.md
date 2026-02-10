# Guia de Setup - Dotfiles

Compatível com Windows 11 + WSL Ubuntu e Linux Ubuntu 24.04.

---

## 📋 Pré-requisitos

### Estrutura de Diretórios Esperada

Este projeto **assume a seguinte estrutura de pastas**:

```
~/Workspaces/
├── Personal/
│   ├── dotfiles/          ← Este repositório
│   └── (seus projetos)
└── Work/
    └── (seus projetos)
```

**Ou customize via variáveis de ambiente:**

```bash
export DOTFILES_DIR="$HOME/caminho/customizado/dotfiles"
export WORK_DIR="$HOME/caminho/customizado/projetos-trabalho"
export PERSONAL_DIR="$HOME/caminho/customizado/projetos-pessoais"
```

### Requisitos Obrigatórios

- Bash 4.0+
- Zsh (será instalado por `setup.sh`)
- Git (será instalado por `setup.sh`)
- `sudo` (para instalar pacotes)

### Requisitos Opcionais (Recomendados)

- VS Code ou VS Code Insiders (para editor Git)
- ripgrep (`rg`)
- fd ou fdfind (para FZF)
- bat (para pager)
- direnv (auto-installado)

---

## 🚀 Instalação Rápida

### 1️⃣ Clone o Repositório

```bash
git clone https://github.com/mingomax/settings-repository.git ~/Workspace/Personal/dotfiles
cd ~/Workspace/Personal/dotfiles
```

### 2️⃣ Execute Setup Completo

```bash
./setup.sh
```

**Opções disponíveis:**

```bash
./setup.sh                    # Setup completo (recomendado)
./setup.sh --no-packages      # Setup sem instalar/atualizar pacotes
./setup.sh --no-symlinks      # Setup sem criar symlinks
./setup.sh --no-git           # Setup sem configurar Git
./setup.sh -h, --help         # Ver todas as opções
```

### 3️⃣ Pós-Instalação Manual

Após `setup.sh`, complete estes passos manualmente:

#### A. Configure Git User

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@example.com"
```

#### B. Oh My Zsh

Se não foi instalado automaticamente:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### C. Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

After installation, run: `p10k configure`

#### D. Zsh Plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# zsh-completions (opcional)
git clone https://github.com/zsh-users/zsh-completions \
  "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions"
```

#### E. NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

Recarregue shell: `exec zsh`

#### F. SSH Keys

Copie suas chaves SSH (com cuidado para manter privadas):

```bash
cp /caminho/para/suas/chaves/id_* ~/.ssh/keys/
chmod 600 ~/.ssh/keys/id_*     # Chaves privadas
chmod 644 ~/.ssh/keys/*.pub    # Chaves públicas
```

Ou execute o utilitário:

```bash
~/.local/bin/ssh-fix-perms
```

#### G. Direnv (Setup por Projeto)

```bash
# Para projeto pessoal
cd ~/Workspace/Personal
direnv allow

# Para projeto de trabalho
cd ~/Workspace/Work
direnv allow
```

#### H. Recarregue Shell

```bash
exec zsh
```

---

## 🪟 Instalação no WSL (Windows 11)

O setup funciona no WSL com as seguintes recomendações:

### 1. InicializaWSL Ubuntu

```powershell
# Em PowerShell (Windows)
wsl --install -d Ubuntu
```

### 2. Configure Caminho Correto

WSL pode ter diretório home diferente. Configure se necessário:

```bash
# No WSL Ubuntu
export HOME="/home/seu-usuario"
export WORK_DIR="$HOME/Workspaces/Work"
export PERSONAL_DIR="$HOME/Workspaces/Personal"
```

### 3. Execute Setup

```bash
cd ~/Workspaces/Personal/dotfiles
./setup.sh
```

### SSH Setup no WSL

SSH agent no WSL tem particularidades. O script `ssh-agent-start` já lida com isso:

```bash
ssh-fix-perms
ssh-add ~/.ssh/keys/id_ed25519_*
ssh-add -l  # Verificar se chaves foram adicionadas
```

### VS Code + WSL

Se usar VS Code com WSL:

1. Instale extension "Remote - WSL"
2. Configure `EDITOR` para abrir em WSL:

```bash
export EDITOR="code --remote wsl+Ubuntu -w"
```

---

## 🔐 Segurança

### Arquivos Protegidos (`.gitignore`)

Estes arquivos **nunca** são committed pelo git:

```
ssh/keys/id_*              # Chaves privadas SSH
ssh/keys/*.pem             # Certificados privados
ssh/agent.env              # Arquivo SSH agent (máquina-específica)
ssh/agent.sock             # Socket SSH agent
ssh/known_hosts*           # Hosts conhecidos (máquina-específica)
```

### Verificar Segurança

```bash
# Verificar permissões SSH
~/.local/bin/ssh-fix-perms

# Listar chaves carregadas no agent
ssh-add -l

# Testar conexão SSH
ssh -T git@github.com
```

---

## 📝 Configurações Git

### Perfis Automáticos

O Git está configurado para usar perfis diferentes por diretório:

```ini
[includeIf "gitdir:${HOME}/Workspaces/Personal/**"]
  path = ${HOME}/Workspaces/Personal/dotfiles/git/personal.gitconfig

[includeIf "gitdir:${HOME}/Workspaces/Work/**"]
  path = ${HOME}/Workspaces/Personal/dotfiles/git/work.gitconfig
```

Edite `git/personal.gitconfig` e `git/work.gitconfig` com seus dados:

```ini
[user]
  name = Seu Nome
  email = seu.email@example.com

[commit]
  gpgsign = true  # Opcional: assinar commits com SSH
```

### Commit Assinado com SSH

Certifique-se que sua chave SSH está carregada:

```bash
ssh-add ~/.ssh/keys/id_ed25519_github
git commit --allow-empty -m "test: verificando assinatura SSH"
git log --show-signature -1
```

---

## 🛠️ Troubleshooting

### Problem: Shell não carrega zshrc

**Solução:**
```bash
# Verificar syntax
zsh -n ~/.zshrc

# Verificar qual shell está ativo
echo $SHELL

# Configurar zsh como padrão
chsh -s $(which zsh)

# Recarregar
exec zsh
```

### Problem: Git profiles não funcionam

**Verificar:**
```bash
# Validar gitconfig
git config --global --list | grep includeIf

# Testar profile
cd ~/Workspaces/Personal/seu-projeto
git config user.email  # Deve mostrar email pessoal
```

**Se não funcionar:**
- Verifique se paths em `git/gitconfig` estão como `${HOME}`, não `~`
- Execute `git config --global core.excludesFile ~/.gitignore` manualmente

### Problem: SSH Agent não inicia

**Debug:**
```bash
# Testar script manualmente
bash -x ~/.local/bin/ssh-agent-start

# Verificar socket
ls -la ~/.ssh/agent.sock

# Verificar env vars
echo $SSH_AUTH_SOCK
echo $SSH_AGENT_PID
```

**Solução:**
```bash
# Limpar socket antigo
rm -f ~/.ssh/agent.sock ~/.ssh/agent.env

# Reiniciar agent
ssh-agent -a ~/.ssh/agent.sock
eval "$(cat ~/.ssh/agent.env)"

# Carregar chaves novamente
ssh-add ~/.ssh/keys/id_ed25519_*
```

### Problem: Direnv não funciona

**Verificar:**
```bash
which direnv
direnv --version
```

**Reintegrar no Zsh:**
```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
exec zsh
```

### Problem: JAVA_HOME não detectado

**Debug:**
```bash
# Verificar instalação Java
which java
java -version

# Verificar JAVA_HOME
echo $JAVA_HOME
```

**Solução:**
```bash
# Encontrar JAVA
readlink -f $(which java)
# Remove /bin/java para encontrar raiz

# Configurar manualmente em ~/.zshrc:
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
```

### Problem: Locale pt_BR não funciona

**Debug:**
```bash
locale -a | grep pt_BR
```

**Solução:**
```bash
# Gerar locale
sudo locale-gen pt_BR.UTF-8
sudo update-locale

# Ou use UTF-8 padrão
export LANG=C.UTF-8
```

---

## 📚 Referências

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Git Configuration](https://git-scm.com/docs/git-config)
- [SSH Config](https://man.openbsd.org/ssh_config)
- [direnv](https://direnv.net/)
- [EditorConfig](https://editorconfig.org/)

---

## ✅ Verificación Final

Após completar a setup, execute:

```bash
# Verificar Zsh
zsh --version

# Verificar Git
git config --global user.name
git config --global user.email

# Verificar SSH
ssh-add -l

# Verificar Oh-My-Zsh
ls ~/.oh-my-zsh

# Verificar Powerlevel10k
ls ~/.oh-my-zsh/custom/themes/powerlevel10k

# Testar aliases
alias          # Lista todos os aliases
gst            # Git status
d ps           # Docker ps
```

---

**Last Updated:** Feb 9, 2026  
**Tested Environments:** Ubuntu 24.04, WSL Ubuntu 20.04+
