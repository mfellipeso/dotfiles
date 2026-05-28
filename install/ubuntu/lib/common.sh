#!/bin/bash
# =============================================================================
# Helpers compartilhados pelos setup-*.sh (Ubuntu/Debian)
# =============================================================================

# Source guard
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }
err()     { echo -e "${RED}    erro: $*${RESET}"; }

ZSHRC="${ZSHRC:-$HOME/.zshrc}"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# Permite return quando sourced, exit quando executado direto.
_finish() {
  return "${1:-0}" 2>/dev/null || exit "${1:-0}"
}

# apt_install pkg1 pkg2 ...
apt_install() {
  local to_install=()
  local pkg
  for pkg in "$@"; do
    if dpkg -s "$pkg" &>/dev/null; then
      skipped "$pkg já instalado"
    else
      to_install+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    info "Instalando: ${to_install[*]}"
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${to_install[@]}"
    ok "${#to_install[@]} pacote(s) instalado(s)"
  fi
}

# zshrc_append <marker> <bloco>
# marker: substring única usada com grep -qF para idempotência
zshrc_append() {
  local marker="$1" block="$2"
  if grep -qF "$marker" "$ZSHRC" 2>/dev/null; then
    skipped "$marker já presente em $ZSHRC"
    return 0
  fi
  printf '\n%s\n' "$block" >> "$ZSHRC"
  ok "$marker adicionado em $ZSHRC"
}

# enable_service <unit>
enable_service() {
  local unit="$1"
  if systemctl is-enabled --quiet "$unit" 2>/dev/null \
     && systemctl is-active --quiet "$unit" 2>/dev/null; then
    skipped "$unit já habilitado e ativo"
    return 0
  fi
  sudo systemctl enable --now "$unit"
  ok "$unit habilitado e iniciado"
}

# need_cmd <cmd> [hint]
need_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" &>/dev/null; then
    err "$cmd não encontrado${hint:+ — $hint}"
    return 1
  fi
}

# stow_pkg <name>  — linka pacote de $DOTFILES_DIR/configs via stow
stow_pkg() {
  local name="$1"
  need_cmd stow "instale via setup-zsh.sh ou apt install stow" || return 1
  stow --dir="$DOTFILES_DIR/configs" --target="$HOME" "$name"
}
