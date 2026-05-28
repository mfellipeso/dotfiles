#!/bin/bash
set -euo pipefail

# =============================================================================
# ATALHOS DO GNOME (workspaces, janelas, customizados)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

if ! command -v gsettings &>/dev/null; then
  skipped "gsettings não encontrado — pulando setup do GNOME"
  _finish 0
fi

# Helper: aplica gsettings somente se o valor for diferente
gset() {
  local schema="$1" key="$2" value="$3"
  local current
  current="$(gsettings get "$schema" "$key" 2>/dev/null || echo "")"
  if [[ "$current" == "$value" ]]; then
    skipped "$key"
    return 0
  fi
  gsettings set "$schema" "$key" "$value"
  ok "$key = $value"
}

info "Aplicando atalhos do GNOME..."

# --- Reset de atalhos conflitantes -------------------------------------------
gset org.gnome.desktop.wm.keybindings switch-panels          "[]"
gset org.gnome.desktop.wm.keybindings switch-panels-backward "[]"

# --- Controles gerais ---------------------------------------------------------
gset org.gnome.settings-daemon.plugins.media-keys mic-mute "['<Control>Escape']"
gset org.gnome.desktop.wm.keybindings             close    "['<Super>q']"
gset org.gnome.settings-daemon.plugins.media-keys home     "['<Super>e']"

# --- Remove lançar aplicativos (Super+1..9) -----------------------------------
for i in $(seq 1 9); do
  gset org.gnome.shell.keybindings "switch-to-application-$i" "['']"
done

# --- Switch de workspace (Super+0..9, setas) ----------------------------------
for i in $(seq 1 9); do
  gset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "['<Super>$i']"
done
gset org.gnome.desktop.wm.keybindings switch-to-workspace-10    "['<Super>0']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-left  "['<Super><Alt>Left']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super><Alt>Right']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-up    "[]"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-down  "[]"

# --- Mover janela para workspace (Shift+Super+0..9, setas) -------------------
for i in $(seq 1 9); do
  gset org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['<Shift><Super>$i']"
done
gset org.gnome.desktop.wm.keybindings move-to-workspace-10    "['<Shift><Super>0']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-left  "['<Super><Shift>Page_Up']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Shift>Page_Down']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-up    "[]"
gset org.gnome.desktop.wm.keybindings move-to-workspace-down  "[]"

ok "Atalhos padrão aplicados."

# =============================================================================
# ATALHOS CUSTOMIZADOS — adicione novos blocos seguindo o padrão abaixo
# =============================================================================
CUSTOM_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

declare -A CUSTOM_NAMES=(
  [custom0]="gradia"
)
declare -A CUSTOM_COMMANDS=(
  [custom0]="flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE"
)
declare -A CUSTOM_BINDINGS=(
  [custom0]="<Super><Shift>s"
)
# =============================================================================

info "Aplicando atalhos customizados..."

paths="["
for key in "${!CUSTOM_NAMES[@]}"; do
  paths+="'${CUSTOM_BASE}/${key}/', "
done
paths="${paths%, }]"

gset org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$paths"

for key in "${!CUSTOM_NAMES[@]}"; do
  path="${CUSTOM_BASE}/${key}/"
  name="${CUSTOM_NAMES[$key]}"
  command="${CUSTOM_COMMANDS[$key]}"
  binding="${CUSTOM_BINDINGS[$key]}"

  current_name="$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name 2>/dev/null || echo "")"

  if [[ "$current_name" == "'$name'" ]]; then
    current_binding="$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding 2>/dev/null || echo "")"
    if [[ "$current_binding" == "'$binding'" ]]; then
      skipped "$name já configurado"
      continue
    fi
  fi

  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name    "$name"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" command "$command"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding "$binding"
  ok "$name → $binding"
done

ok "Atalhos do GNOME concluídos."
