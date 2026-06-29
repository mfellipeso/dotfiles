#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO HERDR  (Arch)
# =============================================================================
# herdr é um multiplexador de terminal agent-aware (estilo tmux), instalado como
# binário em ~/.local/bin via script oficial. Na primeira execução ele grava um
# config.toml REAL em ~/.config/herdr/, então movemos esse arquivo antes de
# linkar o nosso via stow (mesma lógica do setup-tmux.sh).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

HERDR_CONF="$HOME/.config/herdr/config.toml"
STOW_LINK="$DOTFILES_DIR/herdr/.config/herdr/config.toml"

# --- 1. Instalar herdr --------------------------------------------------------
info "herdr..."
if command -v herdr &>/dev/null; then
  skipped "herdr já instalado ($(herdr --version 2>/dev/null || echo 'versão desconhecida'))"
else
  curl -fsSL https://herdr.dev/install.sh | sh
  ok "herdr instalado"
fi

need_cmd stow "instale via setup-zsh.sh ou pacman -S stow" || _finish 1

# --- 2. Remover config auto-gerado (arquivo real sobrescreve o nosso) ---------
info "Verificando conflitos de config..."
if [[ -f "$HERDR_CONF" && ! -L "$HERDR_CONF" ]]; then
  mv "$HERDR_CONF" "${HERDR_CONF}.bak"
  ok "config auto-gerada movida para ${HERDR_CONF}.bak"
fi

# --- 3. Stow ------------------------------------------------------------------
info "Verificando symlink do herdr..."
if [[ -L "$HERDR_CONF" && "$(readlink -f "$HERDR_CONF")" == "$(readlink -f "$STOW_LINK")" ]]; then
  skipped "config.toml já linkado"
else
  stow_pkg herdr
  ok "config.toml linkado via stow"
fi

ok "Setup do herdr concluído."
