#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO UFW (firewall)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Pacote ----------------------------------------------------------------
info "ufw..."
pacman_install ufw

# --- 2. Políticas padrão ------------------------------------------------------
info "Configurando políticas padrão..."
current_incoming="$(sudo ufw status verbose 2>/dev/null | awk '/^Default:/ { for(i=1;i<=NF;i++) if ($i=="incoming") print $(i-1) }')"
current_outgoing="$(sudo ufw status verbose 2>/dev/null | awk '/^Default:/ { for(i=1;i<=NF;i++) if ($i=="outgoing") print $(i-1) }')"

if [[ "$current_incoming" == "deny" ]]; then
  skipped "default incoming já é deny"
else
  sudo ufw default deny incoming
  ok "default incoming: deny"
fi

if [[ "$current_outgoing" == "allow" ]]; then
  skipped "default outgoing já é allow"
else
  sudo ufw default allow outgoing
  ok "default outgoing: allow"
fi

# --- 3. Habilitar UFW ---------------------------------------------------------
info "Verificando status do ufw..."
if sudo ufw status | grep -q "^Status: active"; then
  skipped "ufw já está ativo"
else
  sudo ufw --force enable
  ok "ufw habilitado"
fi

# --- 4. Habilitar serviço -----------------------------------------------------
if systemctl is-enabled --quiet ufw 2>/dev/null; then
  skipped "serviço ufw já habilitado"
else
  sudo systemctl enable ufw
  ok "serviço ufw habilitado"
fi

ok "Setup do UFW concluído."
