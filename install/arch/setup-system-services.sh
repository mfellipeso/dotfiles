#!/bin/bash
set -euo pipefail

# =============================================================================
# SERVIÇOS DE SISTEMA — bluetooth, power-profiles-daemon, disable arch-update
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. power-profiles-daemon ------------------------------------------------
info "power-profiles-daemon..."
pacman_install power-profiles-daemon
enable_service power-profiles-daemon

# --- 2. bluetooth -------------------------------------------------------------
info "bluetooth..."
enable_service bluetooth

# --- 3. Desabilitar arch-update tray/timer (CachyOS) -------------------------
info "Desabilitando arch-update tray/timer (global)..."
for unit in arch-update-tray.service arch-update.timer; do
  state="$(systemctl --global is-enabled "$unit" 2>/dev/null || echo "disabled")"
  if [[ "$state" == "disabled" || "$state" == "not-found" || "$state" == "masked" ]]; then
    skipped "$unit já está $state"
  else
    sudo systemctl --global disable "$unit"
    ok "$unit desabilitado"
  fi
done

ok "Setup de serviços de sistema concluído."
