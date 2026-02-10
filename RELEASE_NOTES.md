# ⚠️ RELEASE NOTES - Versão 2.0

**Data:** 9 de Fevereiro de 2026  
**Versão:** 2.0 (Compatibilidade WSL + Linux)  
**Status:** ✅ STABLE

---

## 🎉 O Que Mudou (Visão Geral)

Esta é uma **grande release** focada em compatibilidade e robustez:

### ✨ Principais Melhorias

- ✅ **WSL (Windows 11) agora suportado**
- ✅ **Paths dinâmicos** (não mais hardcoded)
- ✅ **Detecção automática** de ferramentas e ambiente
- ✅ **Documentação completa** (3 guias novos)
- ✅ **Scripts melhorados** com fallbacks inteligentes
- ✅ **Compatibilidade** com múltiplas distribuições Linux

---

## ⚠️ BREAKING CHANGES

### ❗ Estrutura de Pastas

A estrutura de pastas esperada **mudou**:

```
~/Workspaces/Personal/dotfiles/
~/Workspaces/Work/
```

**✅ Solução para manter estrutura antiga:**

```bash
export DOTFILES_DIR="$HOME/projects/personal/dotfiles"
export WORK_DIR="$HOME/projects/work"
export PERSONAL_DIR="$HOME/projects/personal"
./setup.sh
```

---

### ❗ Git Profiles Podem Precisar Reconfiguração

Se GitprofilES não funcionavam antes, agora funcionarão! Mas você precisa:

1. Verificar `git/gitconfig` está usando `${HOME}` (não `~`)
2. Verificar paths estão corretos para sua estrutura

```bash
git config --global core.excludesFile ~/.gitignore
git config --global core.attributesFile ~/.gitattributes
```

---

### ❗ Deprecated: `install.sh`

O script `install.sh` foi **descontinuado**.

**USE:** `./setup.sh` em seu lugar.

**Migração:**
```bash
# Antigo (não use mais)
# ./install.sh

# Novo (use este)
./setup.sh
```

---

## 🔧 MUDANÇAS TÉCNICAS IMPORTANTES

### 1. Git Config - Paths com `${HOME}`
```ini
# ANTES
[includeIf "gitdir:~/Workspaces/Personal/**"]

# DEPOIS
[includeIf "gitdir:${HOME}/Workspace/Personal/**"]
```

### 2. SSH Agent - Socket Portável
```bash
# ANTES
ss -xl | grep -q "$SOCK"  # Não funciona em WSL

# DEPOIS  
[ -S "$SOCK" ]  # Portável e funciona em WSL
```

### 3. Java Home - Detectado Dinamicamente
```bash
# ANTES
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"  # Hardcoded

# DEPOIS
# Detecta automaticamente a instalação Java do sistema
```

### 4. FD/FDFIND - Suporte Multi-Sistema
```bash
# ANTES
alias fd='fdfind'  # Assume Ubuntu, quebra em outras distros

# DEPOIS
# Detecta automaticamente qual está disponível
```

---

## ✅ O QUE CONTINUE IGUAL (Compatível)

- ✅ Aliases Git funcionam igual
- ✅ SSH config continua igual
- ✅ Zsh/Oh-My-Zsh continua igual
- ✅ `.gitignore` global continua igual
- ✅ Diretórios criados continuam iguais

**Você pode usar a mesma configuração, apenas execute setup novamente.**

---

## 🚀 COMO ATUALIZAR

### Opção 1: Fresh Install (recomendado)

```bash
cd ~/Workspace/Personal/dotfiles
git pull origin main
./setup.sh
```

### Opção 2: Manter Configurações

```bash
# Fazer backup de dados sensíveis (SSH keys, etc)
cp -r ~/.ssh/keys ~/backup-ssh-keys

# Atualizar dotfiles
cd ~/Workspace/Personal/dotfiles
git pull origin main

# (Opcional) Setup novamente se estrutura mudou
./setup.sh --no-packages  # Sem reinstalar pacotes
```

---

## 📚 DOCUMENTAÇÃO NOVA

Leia estes documentos para detalhes:

1. **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Guia completo de instalação
   - Instalação passo-a-passo
   - Setup especial para WSL
   - Troubleshooting
   - Pós-instalação manual

2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Referência rápida
   - Setup em 30 segundos
   - Troubleshooting rápido
   - Aliases comuns

---

## 🔍 TESTE ANTES DE USAR

**Execute o validador para ver se está tudo OK:**

```bash
./validate.sh
```

Deve mostrar ✓ para tudo (exceto itens opcionais).

---

## 🆘 PROBLEMAS CONHECIDOS

### Problem: "Git profiles não funcionam"

**Causa:** Paths em `git/gitconfig` usam `~` que não é expandido.

**Solução:**
1. Verificar `git/gitconfig` tem `${HOME}` (não `~`)
2. Executar `./setup.sh` novamente
3. Verificar paths estão corretos para sua estrutura

```bash
git config --global core.excludesFile ~/.gitignore
```

### Problem: "SSH Agent não inicia"

**Causa:** Socket antigo corrompido.

**Solução:**
```bash
rm -f ~/.ssh/agent.sock ~/.ssh/agent.env
exec zsh
```

### Problem: WSL não reconhece direnv

**Causa:** direnv precisa de integração no `.zshrc`.

**Solução:**
```bash
# Já feito! Mas se não funcionar:
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
exec zsh
```

---

## 🎯 MIGRAÇÃO PASSO-A-PASSO

Se vinha usando v1.x, faça assim:

### 1. Backup (opcional mas recomendado)
```bash
mkdir -p ~/backups/dotfiles-v1
cp -r ~/.ssh ~/backups/dotfiles-v1/
cp -r ~/.oh-my-zsh ~/backups/dotfiles-v1/
```

### 2. Update Dotfiles
```bash
cd ~/Workspaces/Personal/dotfiles  # ou seu path customizado
git pull origin main
```

### 3. Re-run Setup
```bash
./setup.sh
```

### 4. Customize Se Necessário
```bash
# Se estrutura de pastas é diferente
export DOTFILES_DIR="$HOME/your/custom/path"
# Setup já detectará
```

### 5. Validar
```bash
./validate.sh
git config user.email  # Verificar que profile funciona
ssh-add -l             # Verificar SSH keys
```

---

## ✨ NOVAS FEATURES

### 1. Detecção Automática de Ambiente
```bash
# Detecta WSL vs Linux nativo
# Detecta distribuição (Ubuntu, Fedora, Arch)
# Detecta qual editor está disponível
# Detecta qual versão de fd/fdfind
```

### 2. Variáveis de Ambiente Customizáveis
```bash
export DOTFILES_DIR="custom/path"
export WORK_DIR="custom/path"
export PERSONAL_DIR="custom/path"
./setup.sh
```

### 3. Script de Validação
```bash
./validate.sh  # Verifica se tudo foi instalado
```

### 4. Detecção de JAVA_HOME
```bash
# Antes: hardcoded, quebrava em ARM ou java-20
# Depois: Detecta dinamicamente qualquer instalação Java
```

---

## 📊 COMPATIBILIDADE

| Ambiente | Status | Testado |
|----------|--------|---------|
| Ubuntu 24.04 (nativo) | ✅ Full | Sim |
| Windows 11 + WSL | ✅ Full | Sim |
| Debian 11+ | ⚠️ Partial | Não |
| Fedora/RHEL | ⚠️ Partial | Não |
| macOS | ❌ Não | Não |
| CentOS 7 | ❌ Não | Não |

---

## 🔐 SEGURANÇA

**Nada mudou:**
- SSH keys ainda protegidas (`.gitignore`)
- Sem passwords em repositório
- Permissões SSH mantidas corretas

**Melhorado:**
- Script `ssh-fix-perms` mais robusto
- SSH agent usa socket portável
- Compatível com WSL (menos restrições)

---

## 📈 PERFORMANCE

- ✅ Zsh inicia mais rápido (menos checks)
- ✅ Git profiles funcionam imediatamente
- ✅ SSH agent inicia na primeira vez
- ⚠️ Slight overhead na detecção de JAVA_HOME (negligível)

---

## 🔄 ROLLBACK (Reverter para v1.x)

```bash
# Se precisar voltar
cd ~/Workspaces/Personal/dotfiles
git log --oneline | head  # Ver commits
git checkout <commit-v1>  # Volta para v1

# Ou
git checkout main~20  # 20 commits atrás (aproximado)
```

---

## 📞 FEEDBACK & ISSUES

- **Problemas?** Veja [SETUP_GUIDE.md Troubleshooting](SETUP_GUIDE.md#-troubleshooting)
- **Sugestões?** [GitHub Issues](https://github.com/mingomax/dotfiles/issues)

---

## ✅ CHECKLIST DE MIGRAÇÃO

- [ ] Li [RELEASE_NOTES.md](RELEASE_NOTES.md) (este arquivo)
- [ ] Fiz backup se necessário (`cp -r ~/.ssh ~/backup/`)
- [ ] Executei `./setup.sh`
- [ ] Executei `./validate.sh` com sucesso ✓
- [ ] Configurei Git user/email manualmente
- [ ] Testei Git profile: `git config user.email` mostra dados certos
- [ ] Testei SSH: `ssh -T git@github.com`
- [ ] Testei alias: `gst` mostra status
- [ ] Recarreguei shell: `exec zsh`

---

## 🙏 Obrigado

Obrigado por usar dotfiles! Suas sugestões e problemas relatados ajudam a melhorar esta ferramenta.

---

**Versão:** 2.0  
**Data:** Feb 9, 2026  
**Compatibilidade:** Windows 11 WSL + Ubuntu  
**Status:** ✅ STABLE
