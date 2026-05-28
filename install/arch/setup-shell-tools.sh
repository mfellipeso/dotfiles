#!/bin/bash
set -euo pipefail

# =============================================================================
# FERRAMENTAS DE SHELL — zoxide, nano (syntax), nvm
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. zoxide ----------------------------------------------------------------
info "zoxide..."
pacman_install zoxide
zshrc_append 'zoxide init zsh' 'eval "$(zoxide init zsh --cmd cd)"'

# --- 2. nano + syntax ---------------------------------------------------------
info "nano-syntax-highlighting..."
pacman_install nano-syntax-highlighting

NANORC="$HOME/.nanorc"
INCLUDE_LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'
if grep -qF "$INCLUDE_LINE" "$NANORC" 2>/dev/null; then
  skipped "include já presente em $NANORC"
else
  printf '%s\n' "$INCLUDE_LINE" >> "$NANORC"
  ok "include adicionado em $NANORC"
fi

# --- 3. nvm + node LTS --------------------------------------------------------
info "nvm..."
pacman_install nvm

NVM_BLOCK='# NVM
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh'
zshrc_append '/usr/share/nvm/init-nvm.sh' "$NVM_BLOCK"

info "Verificando node via nvm..."
export NVM_DIR="$HOME/.nvm"
set +euo pipefail
source /usr/share/nvm/init-nvm.sh
set -euo pipefail

if nvm which node &>/dev/null 2>&1; then
  skipped "node já instalado ($(node --version))"
else
  nvm install node
  ok "node instalado ($(node --version))"
fi

ok "Setup de ferramentas de shell concluído."
