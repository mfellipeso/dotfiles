#!/bin/bash
set -euo pipefail

# =============================================================================
# TAILSCALE  (Arch)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Pacote + serviço ------------------------------------------------------
info "tailscale..."
pacman_install tailscale
enable_service tailscaled

# --- 2. Firewall: libera tráfego vindo da interface da tailnet ----------------
if command -v ufw &>/dev/null && sudo ufw status | grep -q "^Status: active"; then
  if sudo ufw status | grep -q "tailscale0"; then
    skipped "ufw já libera tailscale0"
  else
    sudo ufw allow in on tailscale0
    ok "ufw: tráfego de entrada liberado em tailscale0"
  fi
else
  skipped "ufw inativo — nada a configurar"
fi

# --- 3. Login na tailnet ------------------------------------------------------
info "Verificando login..."
if [[ "$(tailscale status --json 2>/dev/null | grep -m1 '"BackendState"' | cut -d'"' -f4)" == "Running" ]]; then
  skipped "tailscale já conectado ($(tailscale ip -4 2>/dev/null | head -1))"
else
  sudo tailscale up --accept-routes
  ok "tailscale conectado"
fi

# --- 4. Aceitar rotas anunciadas por subnet routers --------------------------
# Preferência persistente: vale em toda inicialização do tailscaled.
info "Verificando accept-routes..."
if sudo tailscale debug prefs 2>/dev/null | grep -q '"RouteAll": true'; then
  skipped "accept-routes já habilitado"
else
  sudo tailscale set --accept-routes
  ok "accept-routes habilitado"
fi

# --- 5. Operator: permite usar `tailscale` sem sudo ---------------------------
info "Verificando operator..."
if sudo tailscale debug prefs 2>/dev/null | grep -q "\"OperatorUser\": \"$USER\""; then
  skipped "operator já é $USER"
else
  sudo tailscale set --operator="$USER"
  ok "operator = $USER"
fi

ok "Setup do tailscale concluído."
