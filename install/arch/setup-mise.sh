#!/bin/bash
set -euo pipefail

# =============================================================================
# MISE — node, Claude Code, Codex, herdr  (Arch)
# =============================================================================
# mise gerencia as versões das ferramentas (global, em ~/.config/mise/config.toml).
# A ativação (mise activate bash) vive em bash/.bashrc;
# os aliases de claude/codex vivem em aliases/.aliases.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. mise ------------------------------------------------------------------
info "mise..."
pacman_install mise

need_cmd mise "falha ao instalar via pacman" || _finish 1

# --- 2. Config (ferramentas e versões) ---------------------------------------
# As ferramentas vivem em mise/.config/mise/config.toml — edite lá.
CONF="$HOME/.config/mise/config.toml"
SRC="$DOTFILES_DIR/mise/.config/mise/config.toml"

info "Verificando config do mise..."
if [[ -L "$CONF" && "$(readlink -f "$CONF")" == "$(readlink -f "$SRC")" ]]; then
  skipped "config.toml já linkado"
else
  backup_unlinked "$CONF"
  stow_pkg mise
  ok "config.toml linkado via stow"
fi

# --- 3. Instalar ferramentas do config.toml -----------------------------------
info "mise install..."
mise install --yes
ok "ferramentas em dia"

ok "Setup do mise concluído."
