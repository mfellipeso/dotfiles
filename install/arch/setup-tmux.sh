#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO TMUX  (Arch)
# =============================================================================
# O tmux 3.x prefere ~/.config/tmux/tmux.conf sobre ~/.tmux.conf. O Omarchy
# grava um arquivo REAL nesse caminho (e o sobrescreve via omarchy-refresh-tmux),
# então removemos o arquivo dele antes de linkar o nosso via stow.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  tmux
  stow
)

TMUX_CONF="$HOME/.config/tmux/tmux.conf"
STOW_LINK="$DOTFILES_DIR/tmux/.config/tmux/tmux.conf"

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes do tmux..."
pacman_install "${PACKAGES[@]}"

# --- 2. Remover config do Omarchy / symlink legado ----------------------------
info "Verificando conflitos de config..."

# ~/.tmux.conf legado (perde para o XDG no tmux 3.x) — remove se for symlink.
if [[ -L "$HOME/.tmux.conf" ]]; then
  rm -f "$HOME/.tmux.conf"
  ok "removido ~/.tmux.conf legado (symlink)"
fi

# Arquivo real do Omarchy em ~/.config/tmux/tmux.conf sobrescreve o nosso.
if [[ -f "$TMUX_CONF" && ! -L "$TMUX_CONF" ]]; then
  mv "$TMUX_CONF" "${TMUX_CONF}.omarchy.bak"
  ok "config do Omarchy movida para ${TMUX_CONF}.omarchy.bak"
fi

# --- 3. Stow ------------------------------------------------------------------
info "Verificando symlink do tmux..."
if [[ -L "$TMUX_CONF" && "$(readlink -f "$TMUX_CONF")" == "$(readlink -f "$STOW_LINK")" ]]; then
  skipped "tmux.conf já linkado"
else
  stow_pkg tmux
  ok "tmux.conf linkado via stow"
fi

ok "Setup do tmux concluído."
