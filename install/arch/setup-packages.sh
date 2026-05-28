#!/bin/bash
set -euo pipefail

# =============================================================================
# PACOTES — adicione ou remova pacotes aqui
# =============================================================================

PACKAGES=(
  # --- Sistema ---
  base-devel
  ufw
  fzf
  ripgrep
  fd
  bat
  eza
  zsh
  lazygit
  btop
  fastfetch
  unzip
  wget
  curl
  jq
  ptyxis
  nano
  fuse2
  libreoffice-fresh
  libreoffice-fresh-pt-br
  wl-clipboard

  # --- Dev ---
  git
  go

  # --- Codecs ---
  gst-libav
  gst-plugins-base
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  x265
  x264
  lame

  # --- Fontes ---
  adobe-source-sans-pro-fonts
  ttf-dejavu
  ttf-opensans
  noto-fonts
  freetype2
  terminus-font
  ttf-bitstream-vera
  ttf-droid
  ttf-fira-mono
  ttf-fira-sans
  ttf-freefont
  ttf-inconsolata
  ttf-liberation
  otf-libertinus
  ttf-jetbrains-mono-nerd
)

# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

info "Verificando pacotes..."
pacman_install "${PACKAGES[@]}"
ok "Setup de pacotes concluído."
