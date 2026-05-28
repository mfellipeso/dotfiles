#!/bin/bash
set -euo pipefail

# =============================================================================
# INSTALAÇÃO DO NEOVIM (release oficial em /opt)  (Ubuntu)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

NVIM_URL='https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz'
NVIM_PREFIX='/opt/nvim-linux-x86_64'
NVIM_BIN="$NVIM_PREFIX/bin/nvim"

PATH_MARKER="$NVIM_PREFIX/bin"
PATH_BLOCK='# Neovim
export PATH="$PATH:'"$NVIM_PREFIX"'/bin"'

# --- 1. Instalação do binário -------------------------------------------------
info "Verificando neovim em $NVIM_PREFIX..."
if [[ -x "$NVIM_BIN" ]]; then
  skipped "neovim já instalado ($("$NVIM_BIN" --version | head -n1)) — remova $NVIM_PREFIX para reinstalar"
else
  need_cmd curl || _finish 1
  tmp_tarball="$(mktemp -d)/nvim-linux-x86_64.tar.gz"
  info "Baixando neovim (latest)..."
  curl -fL -o "$tmp_tarball" "$NVIM_URL"
  sudo rm -rf "$NVIM_PREFIX"
  sudo tar -C /opt -xzf "$tmp_tarball"
  rm -f "$tmp_tarball"
  ok "neovim instalado em $NVIM_PREFIX ($("$NVIM_BIN" --version | head -n1))"
fi

# --- 2. PATH no bashrc e zshrc (se existirem) --------------------------------
info "Verificando PATH do nvim nos rc files..."
rc_append "$PATH_MARKER" "$PATH_BLOCK"

ok "Setup do neovim concluído."
