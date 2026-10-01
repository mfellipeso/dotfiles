#!/bin/bash
set -euo pipefail

# =============================================================================
# FERRAMENTAS DE SHELL — nano (syntax)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. nano + syntax ---------------------------------------------------------
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

ok "Setup de ferramentas de shell concluído."
