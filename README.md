# Dotfiles - Personal Linux Environment Configuration

Configurações completas para ambiente Linux com Git, SSH, Zsh, VS Code e mais.

## 📋 Estrutura

```
dotfiles/
├── config/                        # Configurações de ferramentas
│   └── direnv/                    # direnv config
├── git/                           # Configurações Git
│   ├── gitconfig                  # Config principal do Git
│   ├── personal.gitconfig         # Perfil pessoal
│   ├── work.gitconfig             # Perfil trabalho
│   ├── aliases.zsh                # Aliases Git para Zsh
│   ├── gitignore                  # Global gitignore
│   ├── gitattributes              # Global gitattributes
│   └── allowed_signers            # Chaves SSH autorizadas para assinatura
├── ssh/                           # Configuração SSH
│   ├── config                     # SSH main config
│   ├── config.d/                  # SSH host-specific configs
│   ├── ssh-agent-start            # Script para iniciar SSH agent
│   ├── ssh-fix-perms              # Script para corrigir permissões SSH
│   └── sync-ssh-from-dropbox.sh   # Script para sincornizar arquivos do Dropbox
├── zsh/                           # Configuração Zsh
│   ├── zshrc                      # Config Zsh
│   └── aliases.zsh                # Aliases gerais (docker, k8s, mvn)
├── phpstorm/                      # Configurações PHPStorm/JetBrains
├── vscode/                        # Configurações VS Code
├── .editorconfig                  # EditorConfig universal
├── .gitignore                     # Git ignore patterns (repositório)
└── setup.sh                       # Script de instalação
```

## 🚀 Quick Start

### 1. Clone o repositório

```bash
git clone https://github.com/mingomax/settings-repository.git ~/Workspaces/Personal/dotfiles
cd ~/Workspaces/Personal/dotfiles
```

### 2. Execute o setup

```bash
./setup.sh
```

**Opções disponíveis:**

```bash
./setup.sh                    # Setup completo
./setup.sh --no-packages      # Sem instalar pacotes
./setup.sh --no-symlinks      # Sem criar symlinks
./setup.sh --no-git           # Sem configurar Git
./setup.sh -h                 # Mostra ajuda
```

### 3. Pré-requisitios (Configurações manuais)

#### Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Powerlevel10k Theme
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

#### Zsh Plugins
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

#### NVM (Node Version Manager)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

#### SSH Keys
```bash
# Copie suas chaves SSH para ~/.ssh/keys/
cp /path/to/your/keys/* ~/.ssh/keys/

# Corrija permissões
~/.local/bin/ssh-fix-perms
```

## 🔐 Segurança

### Arquivos Protegidos (em .gitignore)

Os seguintes arquivos **nunca** serão commitados:

- `ssh/keys/id_*` - Chaves privadas SSH
- `ssh/keys/*.pem` - Certificados privados
- `ssh/agent.env` - Arquivo de ambiente do SSH agent
- `ssh/agent.sock` - Socket do SSH agent
- `ssh/known_hosts*` - Hosts conhecidos (específico da máquina)

### Chaves SSH Comprometidas

1. **Revogue as chaves comprometidas**
   ```bash
   # Notifique os serviços (GitHub, GitLab, etc.)
   # Remova as chaves dos servidores
   ```

2. **Gere novas chaves**
   ```bash
   ssh-keygen -t ed25519 -C "seu-email@example.com"
   ```

3. **Faça clean-up do histórico Git** (se necessário)
   ```bash
   git-filter-branch ou BFG Repo-Cleaner
   ```

## 🔧 Configuração Git

### Perfis Automáticos

O Git está configurado para usar perfis diferentes baseado no diretório:

```gitconfig
[includeIf "gitdir:/home/usuario/Workspaces/Professional/**"]
  path = .../git/work.gitconfig

[includeIf "gitdir:/home/usuario/Workspaces/Personal/**"]
  path = .../git/personal.gitconfig
```

### Globais do Git (ignore e attributes)

O `gitconfig` aponta para arquivos globais no `$HOME`, que devem ser criados via symlink pelo `setup.sh`:

```ini
[core]
   excludesFile = ~/.gitignore
   attributesFile = ~/.gitattributes
```

- `git/gitignore` -> `~/.gitignore` (ignores globais por sistema e stacks)
- `git/gitattributes` -> `~/.gitattributes` (normalizacao de fim de linha e binarios)

### Assinatura de Commits

Commits são assinados automaticamente com SSH:

```bash
# Certifique-se que GPG SSH está configurado
export GPG_TTY=$(tty)

# Teste a assinatura
git commit --allow-empty -m "test: verificando assinatura SSH"
git log --show-signature -1
```

## 🐚 Configuração Shell

### Variáveis de Ambiente

O `.zshrc` carrega automaticamente:
- NVM (Node Version Manager)
- direnv
- SSH Agent vars
- Java/Maven
- Docker aliases

### SSH Agent Auto-start

O script `ssh-agent-start` é executado automaticamente via `direnv`:

```bash
# No arquivo config/direnv/direnvrc:
source_env ~/.ssh/agent.env
```

Ou manualmente:
```bash
~/.local/bin/ssh-agent-start
```

## 📝 Estrutura de Aliases

### Git Aliases (em `git/aliases.zsh`)
- `gst` - git status -sb
- `ga`  - git add -A
- `gcm` - git commit -m
- `gp`  - git push
- `gl`  - git pull (com rebase/autostash via gitconfig)
- `glg` - git log com graph

### Aliases gerais (em `zsh/aliases.zsh`)
- `d`  - docker
- `dc` - docker compose
- `k`  - kubectl
- `mvnci` - Maven clean install sem testes
- `qdev`  - Quarkus dev mode

## 🛠️ Troubleshooting

### SSH não funciona após setup

```bash
# Verifique permissões
~/.local/bin/ssh-fix-perms

# Verifique SSH agent
echo $SSH_AUTH_SOCK
ssh-add -l

# Reinicie shell
exec zsh
```

### Git não reconhece assinatura SSH

```bash
# Reconfigure allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

# Verifique chave SSH
ssh-add -l
```

### Zsh não é o shell padrão

```bash
# Altere novamente
chsh -s $(which zsh)
```

### direnv não funciona

```bash
# Verifique instalação
which direnv
direnv --version

# Integre ao Zsh novamente
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

## 📚 Referências

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Git Config](https://git-scm.com/docs/git-config)
- [SSH Config](https://man.openbsd.org/ssh_config)
- [direnv](https://direnv.net/)
- [EditorConfig](https://editorconfig.org/)

## 📝 Licença

Pessoal - Compartilhe como achar melhor!

## 👤 Autor

Domingos Teruel (mingomax)

---

**Última atualização:** Feb 4, 2026
