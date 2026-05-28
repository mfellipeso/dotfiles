#!/bin/bash
set -euo pipefail

# =============================================================================
# INSTALAÇÃO DO NVM (Node Version Manager)  (Ubuntu)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

NVM_VERSION='v0.40.4'
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

NVM_MARKER='NVM_DIR/nvm.sh'
NVM_BLOCK='# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm'

# --- 1. Instalação ------------------------------------------------------------
info "Verificando nvm em $NVM_DIR..."
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  skipped "nvm já instalado em $NVM_DIR"
else
  need_cmd curl || _finish 1
  info "Instalando nvm $NVM_VERSION..."
  # O installer pode acrescentar seu próprio bloco aos rc files; o rc_append
  # abaixo usa grep -qF e não duplica.
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  ok "nvm instalado"
fi

# --- 2. Bloco no bashrc e zshrc (se existirem) -------------------------------
info "Verificando bloco do nvm nos rc files..."
rc_append "$NVM_MARKER" "$NVM_BLOCK"

# --- 3. Node mais recente via nvm --------------------------------------------
info "Verificando node via nvm..."
export NVM_DIR
# nvm.sh assume shell não-estrito; relaxa durante o source.
set +euo pipefail
\. "$NVM_DIR/nvm.sh"
set -euo pipefail

if nvm which node &>/dev/null; then
  skipped "node já instalado ($(node --version))"
else
  nvm install node
  ok "node instalado ($(node --version))"
fi

ok "Setup do nvm concluído."
