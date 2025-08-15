# ========= P10k instant prompt (deixe no topo) =========
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========= PATH básico =========
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# ========= Oh My Zsh =========
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Se aparecer warning de compfix, descomente:
# ZSH_DISABLE_COMPFIX="true"

plugins=(
  git
  docker docker-compose
  kubectl
  colored-man-pages
  command-not-found
  history-substring-search
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting   # deve ser o último
)

source "$ZSH/oh-my-zsh.sh"

# ========= Preferências gerais =========
ENABLE_CORRECTION="true"
export PROMPT_DIRTRIM=3
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export EDITOR="code-insiders -w"

# ========= Java / Maven =========
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

# ========= Aliases úteis (Java/Maven/Quarkus) =========
alias mvnci='mvn -T 1C -U -e -DskipTests clean install'
alias mvnrt='mvn -T 1C -DskipTests'
alias qdev='mvn quarkus:dev'

# ========= Node/NPM/NVM =========
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# ========= Docker & Kubernetes =========
alias d='docker'
alias dc='docker compose'
alias k='kubectl'

# ========= fzf / bat / fd =========
alias fd='fdfind'  # no Ubuntu o binário chama fdfind
export FZF_DEFAULT_COMMAND='fdfind --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height=40% --border --inline-info'

export PAGER="bat"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ========= zoxide =========
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ========= direnv =========
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ========= Histórico =========
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS \
       EXTENDED_HISTORY SHARE_HISTORY INC_APPEND_HISTORY
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ========= Qualidade de vida =========
setopt autocd auto_pushd pushd_silent pushd_ignore_dups
setopt correct
setopt interactivecomments
unsetopt beep

# ===== Navegação pessoal =====
alias work='cd "$HOME/Workspaces/Professional/ciandt"'
alias personal='cd "$HOME/Workspaces/Personal"'
alias tools='cd "$HOME/Tools"'

# ========= Git aliases =========
alias gst='git status -sb'
alias ga='git add -A'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gco='git checkout'
alias gb='git switch -c'
alias gp='git push'
alias gl='git pull --rebase --autostash'
alias gd='git diff'
alias glg='git log --oneline --graph --decorate -n 30'
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# ========= Powerlevel10k (config do prompt) =========
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
