#!/bin/bash
set -euo pipefail

# =============================================================================
# SUPORTE A L2TP/IPSec VPN
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

need_cmd nmcli "instale NetworkManager primeiro" || _finish 1

PACKAGES=(networkmanager-l2tp strongswan)

info "Pacotes L2TP..."
before="$(pacman -Qq "${PACKAGES[@]}" 2>/dev/null | wc -l)"
pacman_install "${PACKAGES[@]}"
after="$(pacman -Qq "${PACKAGES[@]}" 2>/dev/null | wc -l)"

# Reinicia NetworkManager apenas se houve nova instalação
if [[ "$before" != "$after" ]]; then
  info "Reiniciando NetworkManager..."
  sudo systemctl restart NetworkManager
  ok "NetworkManager reiniciado"
else
  skipped "NetworkManager não precisa reiniciar"
fi

ok "Setup L2TP concluído."
