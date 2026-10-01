#!/bin/bash
set -euo pipefail

# =============================================================================
# BASH + STARSHIP + FZF + ZOXIDE  (Arch) — estrutura do Omarchy
# =============================================================================
# ~/.bashrc único (estilo Omarchy): history, completion, mise, starship, zoxide, fzf.
# Linkado via stow (pacotes: bash, starship, aliases).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  bash
  bash-completion
  starship
  fzf
  zoxide
  eza
  stow
)

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes do bash..."
pacman_install "${PACKAGES[@]}"

# --- 2. Stow ------------------------------------------------------------------
info "Verificando symlinks..."
link_pkg bash .bashrc
link_pkg starship .config/starship.toml
link_pkg aliases .aliases

# --- 3. Definir bash como shell padrão ---------------------------------------
info "Verificando shell padrão..."
if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$(command -v bash)" ]]; then
  skipped "bash já é o shell padrão"
else
  chsh -s "$(command -v bash)"
  ok "bash definido como shell padrão (efetivo no próximo login)"
fi

ok "Setup do bash concluído."
