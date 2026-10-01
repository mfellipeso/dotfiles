#!/bin/bash
# =============================================================================
# Helpers compartilhados pelos setup-*.sh
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

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# Permite return quando sourced, exit quando executado direto.
_finish() {
  return "${1:-0}" 2>/dev/null || exit "${1:-0}"
}

# pacman_install pkg1 pkg2 ...
pacman_install() {
  local to_install=()
  local pkg
  for pkg in "$@"; do
    if pacman -Q "$pkg" &>/dev/null; then
      skipped "$pkg já instalado"
    else
      to_install+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    info "Instalando: ${to_install[*]}"
    sudo pacman -S --noconfirm "${to_install[@]}"
    ok "${#to_install[@]} pacote(s) instalado(s)"
  fi
}

# backup_unlinked <path>
# Move um arquivo real (não-symlink) para <path>.bak, liberando o caminho pro stow.
backup_unlinked() {
  local path="$1"
  if [[ -e "$path" && ! -L "$path" ]]; then
    mv "$path" "${path}.bak"
    ok "$path movido para ${path}.bak"
  fi
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

# btrfs_subvol_nocow <path> [stop_service_during_migration]
btrfs_subvol_nocow() {
  local path="$1" stop_svc="${2:-}"
  local fs
  fs="$(findmnt -n -o FSTYPE /)"
  if [[ "$fs" != "btrfs" ]]; then
    skipped "FS é '$fs', sem configuração btrfs necessária"
    return 0
  fi

  info "btrfs detectado — verificando subvolume $path..."
  if sudo btrfs subvolume show "$path" &>/dev/null; then
    skipped "subvolume $path já existe"
  else
    [[ -n "$stop_svc" ]] && sudo systemctl stop "$stop_svc" 2>/dev/null || true
    sudo mkdir -p "$(dirname "$path")"
    if [[ -d "$path" ]]; then
      sudo mv "$path" "${path}.bak"
    fi
    sudo btrfs subvolume create "$path"
    if [[ -d "${path}.bak" ]]; then
      sudo mv "${path}.bak"/* "$path"/ 2>/dev/null || true
      sudo rm -rf "${path}.bak"
    fi
    ok "subvolume $path criado"
  fi

  if lsattr -d "$path" 2>/dev/null | grep -q 'C'; then
    skipped "CoW já desativado em $path"
  else
    sudo chattr +C "$path"
    ok "CoW desativado em $path"
  fi
}

# need_cmd <cmd> [hint]
need_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" &>/dev/null; then
    err "$cmd não encontrado${hint:+ — $hint}"
    return 1
  fi
}

# stow_pkg <name>  — linka pacote de $DOTFILES_DIR via stow
stow_pkg() {
  local name="$1"
  command -v stow &>/dev/null || pacman_install stow
  stow --dir="$DOTFILES_DIR" --target="$HOME" "$name"
}

# link_pkg <pacote> <caminho relativo a $HOME que deve apontar pro repo>
# Idempotente: pula se já linkado; faz backup de arquivo/diretório real antes do stow.
link_pkg() {
  local pkg="$1" rel="$2"
  local target="$HOME/$rel" src="$DOTFILES_DIR/$pkg/$rel"
  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$src")" ]]; then
    skipped "$rel já linkado"
    return 0
  fi
  backup_unlinked "$target"
  stow_pkg "$pkg"
  ok "$pkg linkado via stow"
}
