# 🔐 SSH Setup (WSL) – Work & Personal

Este repositório documenta a configuração de SSH utilizada no meu ambiente

**Windows 11 + WSL (Ubuntu)**, com separação clara entre **work** e **personal**,
uso de **ssh-agent persistente** e configuração modular via `config.d`.

O objetivo é:
- nunca misturar contas pessoais e corporativas
- evitar erros de commit/autenticação
- tornar o setup reproduzível em minutos

---

## 📁 Estrutura

### Dotfiles (versionado)
```

dotfiles/
└── ssh/
├── config
└── config.d/
├── 00-defaults.conf
├── 10-github-personal.conf
├── 20-github-work.conf
├── 12-bitbucket.conf
└── 90-internal-work.conf

```

### Runtime no WSL (não versionado)
```

~/.ssh/
├── config        -> symlink (dotfiles)
├── config.d/     -> symlink (dotfiles)
├── keys/
│   ├── id_ed25519_personal_github
│   ├── id_ed25519_work_github
│   ├── id_ed25519_mingomax_bitbucket
│   └── ...
└── known_hosts

```

⚠️ **Nunca versionar chaves privadas.**

---

## 🔑 Nomenclatura de chaves

Padrão adotado:
```

id_ed25519_<perfil>_<provedor>

````

Exemplos:
- `id_ed25519_personal_github`
- `id_ed25519_work_github`
- `id_ed25519_work_gitlab`
- `id_ed25519_work_internal`

Permissões obrigatórias:

```bash
chmod 700 ~/.ssh
chmod 700 ~/.ssh/keys
chmod 600 ~/.ssh/keys/id_*
chmod 644 ~/.ssh/keys/*.pub
````

---

## ⚙️ SSH Config (modular)

### `~/.ssh/config`

Arquivo mínimo, apenas inclui os blocos:

```sshconfig
Include ~/.ssh/config.d/*.conf
```

---

### GitHub – Personal

`config.d/10-github-personal.conf`

```sshconfig
Host github.com-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/keys/id_ed25519_personal_github
  IdentitiesOnly yes
```

### GitHub – Work

`config.d/20-github-work.conf`

```sshconfig
Host github.com-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/keys/id_ed25519_work_github
  IdentitiesOnly yes
```

### Bitbucket

`config.d/12-bitbucket.conf`

```sshconfig
Host bitbucket.org
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/keys/id_ed25519_mingomax_bitbucket
  IdentitiesOnly yes
```

---

## 🤖 ssh-agent (WSL)

* Agent persistente com socket fixo: `~/.ssh/agent.sock`
* Inicializado automaticamente via `.zshrc`
* Carrega chaves **somente se ainda não estiverem no agent**
* Passphrase solicitada apenas uma vez por sessão WSL

Script:

```
~/.local/bin/ssh-agent-start
```

Validação:

```bash
echo $SSH_AUTH_SOCK
ssh-add -l
```

---

## 🔄 Clonagem correta de repositórios

### Personal

```bash
git clone git@github.com-personal:mingomax/REPO.git
```

### Work

```bash
git clone git@github.com-work:ORG/REPO.git
```

Isso garante que:

* a chave correta será usada
* o commit será atribuído à conta certa

---

## 🧪 Comandos de diagnóstico

Ver como o SSH resolve um host:

```bash
ssh -G github.com-work | grep -i -E "user|identityfile|identitiesonly"
```

Testar autenticação:

```bash
ssh -T git@github.com-personal
ssh -T git@github.com-work
```

Ver chaves carregadas no agent:

```bash
ssh-add -l
```

---

## 🛠️ Correção rápida de permissões

Se algo quebrar após cópias/sync:

```bash
~/dotfiles/scripts/fix-ssh-perms.sh
```