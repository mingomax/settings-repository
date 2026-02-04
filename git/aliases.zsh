# ===== Status / Logs =====
alias gst='git status -sb'
alias glg='git log --oneline --graph --decorate -n 30'
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gbr='git branch -vv'

# ===== Add / Commit =====
alias ga='git add -A'
alias gcm='git commit -m'
alias gca='git commit -am'
alias gce='git commit'          # abre editor (mensagem + body)

# ===== Switch / Branch =====
alias gsw='git switch'
alias gb='git switch -c'        # mantém seu "gb" como create branch
alias gbd='git branch -d'
alias gbD='git branch -D'

# ===== Sync =====
alias gl='git pull'                       # agora puxa com rebase/autostash via config
alias gp='git push'
alias gpf='git push --force-with-lease'   # push forçado seguro
alias gfp='git fetch --prune --tags'      # limpa refs e atualiza tags

# ===== Diff =====
alias gd='git diff'
alias gds='git diff --staged'

# ===== Restore / Unstage (moderno) =====
alias grs='git restore'
alias grss='git restore --staged'
alias gunstage='git restore --staged .'
alias gdiscard='git restore .'

# ===== Rebase (atalhos) =====
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

# ===== Stash =====
alias gsta='git stash push -u -m' # ex: gsta "wip: teste"
alias gstp='git stash pop'
alias gstl='git stash list'