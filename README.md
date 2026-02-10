# Dotfiles - Personal Linux Environment Configuration

Configurações completas para ambiente Linux com Git, SSH, Zsh, VS Code e mais.

**Compatível com:** Windows 11 + WSL Ubuntu || Ubuntu 24.04 (nativo)

⚠️ **[IMPORTANTE] Leia [SETUP_GUIDE.md](SETUP_GUIDE.md) antes de instalar!**

---

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
│   └── scripts/
│       └── fix-ssh-perms.sh       # Versão standalone
├── zsh/                           # Configuração Zsh
│   ├── zshrc                      # Config Zsh
│   └── aliases.zsh                # Aliases gerais (docker, k8s, mvn)
├── phpstorm/                      # Configurações PHPStorm/JetBrains
├── vscode/                        # Configurações VS Code
├── .editorconfig                  # EditorConfig universal
├── .gitignore                     # Git ignore patterns (repositório)
├── bootstrap.sh                   # Script legacy (para casos especiais)
├── SETUP_GUIDE.md                 # Guia detalhado de instalação
└── README.md                      # Este arquivo
```

---

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
./setup.sh                    # Setup completo (recomendado)
./setup.sh --no-packages      # Sem instalar pacotes
./setup.sh --no-symlinks      # Sem criar symlinks  
./setup.sh --no-git           # Sem configurar Git
./setup.sh -h                 # Mostra ajuda
```

### 3. Veja [SETUP_GUIDE.md](SETUP_GUIDE.md) para passos pós-instalação

---

## ⚠️ IMPORTANTES - Antes de Começar

### ✅ Estrutura de Pastas

Este projeto assume a seguinte estrutura:

```
~/Workspaces/
├── Personal/
│   ├── dotfiles/          ← Repositório (aqui)
│   └── (seus projetos)
└── Work/
    └── (seus projetos)
```

Se sua estrutura é diferente, exporte variáveis antes de rodar `setup.sh`:

```bash
export DOTFILES_DIR="$HOME/seu-caminho/dotfiles"
export WORK_DIR="$HOME/seu-caminho/projetos-trabalho"
export PERSONAL_DIR="$HOME/seu-caminho/projetos-pessoais"
./setup.sh
```

### ✅ Ambiente Testado

- ✅ Ubuntu 24.04 (nativo)
- ✅ Windows 11 + WSL Ubuntu 20.04+
- ⚠️ Debian 11+ (com ajustes)
- ❌ CentOS/RHEL (versão básica em `setup.sh`)

### ✅ Requisitos Mínimos

- Bash 4.0+
- Sudo (para instalar pacotes)
- Git (será instalado)
- Zsh (será instalado)

---

## 📚 Documentação

### Começando

1. **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Guia completo de instalação e pós-instalação

### Configuração Específica

- **Git**: Ver seção "🔧 Configuração Git" abaixo
- **SSH**: Ver seção "🔐 Segurança" abaixo  
- **Zsh**: Ver seção "🐚 Configuração Shell" abaixo
- **Aliases**: Ver [zsh/aliases.zsh](zsh/aliases.zsh) e [git/aliases.zsh](git/aliases.zsh)

---

## 🔧 Configuração Git

### Perfis Automáticos (Personal vs Work)

Git está configurado automaticamente para usar perfis diferentes baseado no diretório:

**Em `git/gitconfig`:**
```ini
[includeIf "gitdir:${HOME}/Workspaces/Personal/**"]
  path = ${HOME}/Workspaces/Personal/dotfiles/git/personal.gitconfig

[includeIf "gitdir:${HOME}/Workspaces/Work/**"]
  path = ${HOME}/Workspaces/Personal/dotfiles/git/work.gitconfig
```

### Configurar Seus Dados

Edite `git/personal.gitconfig` e `git/work.gitconfig` com seus dados:

**`git/personal.gitconfig`:**
```ini
[user]
  name = Seu Nome
  email = seu.email.pessoal@example.com

[commit]
  gpgsign = false  # Ou true se quiser assinar commits com SSH
```

**`git/work.gitconfig`:**
```ini
[user]
  name = Seu Nome
  email = seu.email.trabalho@company.com

[commit]
  gpgsign = false
```

### Editor Git

O editor é detectado automaticamente na seguinte ordem:
1. `code-insiders -w` (se instalado)
2. `code -w` (se instalado)
3. `nano` (fallback padrão)

---

## 🐚 Configuração Shell

### Variáveis de Ambiente Detectadas Automaticamente

O `zshrc` detecta automaticamente:

- **JAVA_HOME:** Busca instalação OpenJDK mais recente
- **NVM:** Node Version Manager (se instalado)
- **direnv:** Auto-integração se disponível
- **locale:** pt_BR.UTF-8 se disponível (fallback: C.UTF-8)
- **fd/fdfind:** Detecta qual está disponível

### Aliases Principais

**Git** (em [git/aliases.zsh](git/aliases.zsh)):
```bash
gst    # git status -sb
ga     # git add -A
gcm    # git commit -m
gp     # git push
gl     # git pull (com rebase)
glg    # git log com graph
```

**Sistema** (em [zsh/aliases.zsh](zsh/aliases.zsh)):
```bash
d      # docker
dc     # docker compose
k      # kubectl
mvnci  # mvn clean install (sem testes)
work   # cd ~/Workspace/Work
personal  # cd ~/Workspace/Personal
```

---

## 🔐 Segurança

### Arquivos Protegidos

Os seguintes arquivos **nunca** serão commitados:

```
ssh/keys/id_*              # Chaves privadas SSH
ssh/keys/*.pem             # Certificados privados
ssh/agent.env              # Variáveis de ambiente SSH agent
ssh/agent.sock             # Socket SSH agent
ssh/known_hosts*           # Hosts conhecidos (máquina-específica)
```

### Verificações de Segurança

```bash
# Verificar permissões SSH
~/.local/bin/ssh-fix-perms

# Listar chaves carregadas
ssh-add -l

# Testar autenticação
ssh -T git@github.com
```

---

## 🛠️ Troubleshooting

Veja [SETUP_GUIDE.md#troubleshooting](SETUP_GUIDE.md#-troubleshooting) para soluções detalhadas de problemas comuns.

---

## ✅ Checklist Pós-Setup

Após completar `setup.sh` e os passos em [SETUP_GUIDE.md](SETUP_GUIDE.md):

- [ ] Zsh é o shell padrão: `echo $SHELL`
- [ ] Git user configurado: `git config --global user.name`
- [ ] SSH keys carregadas: `ssh-add -l`
- [ ] Aliases funcionando: `alias | grep gst`
- [ ] Oh-My-Zsh instalado: `ls ~/.oh-my-zsh`
- [ ] Powerlevel10k ativo
- [ ] VS Code editor funciona: `git commit --allow-empty -m "test"`

---

## 📚 Referências

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Git Config](https://git-scm.com/docs/git-config)
- [SSH Config](https://man.openbsd.org/ssh_config)
- [direnv](https://direnv.net/)
- [EditorConfig](https://editorconfig.org/)
- [WSL Docs](https://docs.microsoft.com/en-us/windows/wsl/)

## 📝 Licença

Pessoal - Compartilhe como achar melhor!

## 👤 Autor

Domingos Teruel (mingomax)

---

**Última atualização:** Feb 9, 2026  
**Versão:** 2.0 (Compatível WSL + Linux)
