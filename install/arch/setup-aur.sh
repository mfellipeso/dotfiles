#!/bin/bash
set -euo pipefail

# =============================================================================
# AUR — yay + pacotes do AUR
# =============================================================================
AUR_PACKAGES=(
  google-chrome
  visual-studio-code-bin
)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Garantir yay ----------------------------------------------------------
info "Verificando yay..."
if command -v yay &>/dev/null; then
  skipped "yay já instalado ($(yay --version | head -1))"
else
  info "Instalando yay-bin via AUR..."
  pacman_install base-devel git

  build_dir="$(mktemp -d)"
  git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
  pushd "$build_dir/yay-bin" >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "$build_dir"
  ok "yay instalado"
fi

# --- 2. Instalar pacotes AUR --------------------------------------------------
info "Verificando pacotes AUR..."
to_install=()
for pkg in "${AUR_PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  info "Instalando: ${to_install[*]}"
  yay -S --noconfirm --needed "${to_install[@]}"
  ok "${#to_install[@]} pacote(s) AUR instalado(s)"
fi

ok "Setup do AUR concluído."
