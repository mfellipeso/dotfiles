#!/bin/bash
set -euo pipefail

# =============================================================================
# NEOVIM (LazyVim) + LAZYGIT  (Arch)
# =============================================================================
# Configs linkadas via stow: nvim/.config/nvim e lazygit/.config/lazygit.
# Os plugins são restaurados nas versões do lazy-lock.json.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  neovim
  lazygit
  git
  base-devel       # gcc/make p/ compilar parsers e plugins
  tree-sitter-cli  # nvim-treesitter
  ripgrep          # grep do picker
  fd               # files do picker
  fzf
  unzip            # mason
  wl-clipboard     # clipboard no Wayland
)

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes do neovim..."
pacman_install "${PACKAGES[@]}"

# --- 2. Configs ---------------------------------------------------------------
info "Verificando symlinks..."
link_pkg nvim .config/nvim
link_pkg lazygit .config/lazygit

# --- 3. Plugins (versões do lazy-lock.json) ----------------------------------
info "Restaurando plugins do LazyVim..."
nvim --headless "+Lazy! restore" +qa
ok "plugins em dia"

ok "Setup do neovim concluído."
