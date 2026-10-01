#!/bin/bash
set -euo pipefail

# =============================================================================
# GNOME — apps e extensões
# =============================================================================
PACKAGES=(
  ptyxis                               # terminal do GNOME
  gnome-shell-extension-appindicator   # ícones de bandeja
)
FLATPAKS=(
  com.mattjakeman.ExtensionManager
)
EXTENSIONS=(
  appindicatorsupport@rgcjonas.gmail.com
)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Pacotes ---------------------------------------------------------------
info "Pacotes do GNOME..."
pacman_install "${PACKAGES[@]}"

# --- 2. Flatpaks --------------------------------------------------------------
info "Flatpaks do GNOME..."
need_cmd flatpak "rode setup-flatpaks.sh primeiro" || _finish 1
for app in "${FLATPAKS[@]}"; do
  if flatpak info --user "$app" &>/dev/null; then
    skipped "$app já instalado"
  else
    flatpak install --user -y flathub "$app"
    ok "$app instalado"
  fi
done

# --- 3. Habilitar extensões ---------------------------------------------------
# Via gsettings: funciona mesmo antes do shell recarregar (vale no próximo login).
info "Extensões..."
for ext in "${EXTENSIONS[@]}"; do
  enabled="$(gsettings get org.gnome.shell enabled-extensions)"
  if [[ "$enabled" == *"'$ext'"* ]]; then
    skipped "$ext já habilitada"
  else
    if [[ "$enabled" == "@as []" || "$enabled" == "[]" ]]; then
      gsettings set org.gnome.shell enabled-extensions "['$ext']"
    else
      gsettings set org.gnome.shell enabled-extensions "${enabled%]}, '$ext']"
    fi
    ok "$ext habilitada"
  fi
done

ok "Setup de apps do GNOME concluído."
