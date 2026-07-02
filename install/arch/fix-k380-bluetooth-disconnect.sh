#!/bin/bash
set -euo pipefail

# =============================================================================
# ESTABILIDADE DE CONEXÃO BLUETOOTH
#   UPower NoPollBatteries=true
#     O upowerd polla a bateria de teclados BT (GET_REPORT a cada 30s); quando
#     o poll pega o teclado em sono profundo (ex: K380), o host espera 20s por
#     resposta LMP e derruba o link (Connection Timeout 0x08 — confirmado via
#     captura btmon). Sem polling, o upower trabalha por uevents e a bateria
#     do notebook (ACPI) continua atualizando normal.
# =============================================================================
UPOWER_CONF="/etc/UPower/UPower.conf"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

info "Verificando $UPOWER_CONF..."

if [[ ! -f "$UPOWER_CONF" ]]; then
  err "$UPOWER_CONF não encontrado — pacote upower instalado?"
  _finish 1
fi

if sudo grep -qE '^NoPollBatteries=true$' "$UPOWER_CONF"; then
  skipped "$UPOWER_CONF já está com NoPollBatteries=true"
else
  if sudo grep -qE '^#?NoPollBatteries=' "$UPOWER_CONF"; then
    sudo sed -i 's/^#\?NoPollBatteries=.*/NoPollBatteries=true/' "$UPOWER_CONF"
  else
    echo "NoPollBatteries=true" | sudo tee -a "$UPOWER_CONF" >/dev/null
  fi
  ok "$UPOWER_CONF atualizado (NoPollBatteries=true)"

  if systemctl is-active --quiet upower; then
    info "Reiniciando upower.service..."
    sudo systemctl restart upower
    ok "upower.service reiniciado"
  fi
fi

ok "Setup de estabilidade Bluetooth concluído."
