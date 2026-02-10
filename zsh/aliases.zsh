# ========= Aliases úteis (Java/Maven/Quarkus) =========
alias mvnci='mvn -T 1C -U -e -DskipTests clean install'
alias mvnrt='mvn -T 1C -DskipTests'
alias qdev='mvn quarkus:dev'

# ========= Docker & Kubernetes =========
alias d='docker'
alias dc='docker compose'
alias k='kubectl'

# ========= fzf / bat / fd =========
# fd pode ser nomeado 'fdfind' em Ubuntu (conflito com outro pacote)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# ===== Navegação pessoal =====
# Usar variáveis de ambiente (configuradas no zshrc)
alias work='cd "${WORK_DIR:-$HOME/Workspaces/Work}"'
alias personal='cd "${PERSONAL_DIR:-$HOME/Workspaces/Personal}"'
alias tools='cd "${TOOLS_DIR:-$HOME/Tools}"'
