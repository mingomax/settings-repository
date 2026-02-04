# ========= Aliases úteis (Java/Maven/Quarkus) =========
alias mvnci='mvn -T 1C -U -e -DskipTests clean install'
alias mvnrt='mvn -T 1C -DskipTests'
alias qdev='mvn quarkus:dev'

# ========= Docker & Kubernetes =========
alias d='docker'
alias dc='docker compose'
alias k='kubectl'

# ========= fzf / bat / fd =========
alias fd='fdfind'  # no Ubuntu o binário chama fdfind

# ===== Navegação pessoal =====
alias work='cd "$HOME/Workspaces/Professional/ciandt"'
alias personal='cd "$HOME/Workspaces/Personal"'
alias tools='cd "$HOME/Tools"'
