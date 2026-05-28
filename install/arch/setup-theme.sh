#!/bin/bash
set -euo pipefail

# =============================================================================
# TEMA — adw-gtk-theme + variantes flatpak + GNOME color-scheme dark
# =============================================================================
FLATPAK_THEMES=(
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
)
GTK_THEME="adw-gtk3-dark"
COLOR_SCHEME="prefer-dark"
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Pacote pacman ---------------------------------------------------------
info "adw-gtk-theme..."
pacman_install adw-gtk-theme

# --- 2. Temas flatpak ---------------------------------------------------------
need_cmd flatpak "rode setup-flatpaks.sh primeiro" || _finish 1

info "Temas flatpak..."
for theme in "${FLATPAK_THEMES[@]}"; do
  if flatpak info "$theme" &>/dev/null; then
    skipped "$theme já instalado"
  else
    flatpak install -y flathub "$theme"
    ok "$theme instalado"
  fi
done

# --- 3. Override de filesystem para themes ------------------------------------
info "Verificando override --filesystem=xdg-data/themes..."
if sudo flatpak override --show 2>/dev/null | grep -q 'filesystems=.*xdg-data/themes'; then
  skipped "override xdg-data/themes já aplicado"
else
  sudo flatpak override --filesystem=xdg-data/themes
  ok "override xdg-data/themes aplicado"
fi

# --- 4. Mask dos temas (impede atualização automática) -----------------------
info "Verificando masks dos temas..."
current_masks="$(sudo flatpak mask 2>/dev/null || echo "")"
for theme in "${FLATPAK_THEMES[@]}"; do
  if echo "$current_masks" | grep -qF "$theme"; then
    skipped "$theme já mascarado"
  else
    sudo flatpak mask "$theme"
    ok "$theme mascarado"
  fi
done

# --- 5. GNOME gsettings -------------------------------------------------------
if ! command -v gsettings &>/dev/null; then
  skipped "gsettings não encontrado — pulando ajuste de tema GNOME"
  _finish 0
fi

info "Aplicando tema no GNOME..."
current_theme="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")"
if [[ "$current_theme" == "'$GTK_THEME'" ]]; then
  skipped "gtk-theme já é $GTK_THEME"
else
  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
  ok "gtk-theme = $GTK_THEME"
fi

current_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "")"
if [[ "$current_scheme" == "'$COLOR_SCHEME'" ]]; then
  skipped "color-scheme já é $COLOR_SCHEME"
else
  gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
  ok "color-scheme = $COLOR_SCHEME"
fi

ok "Setup do tema concluído."
