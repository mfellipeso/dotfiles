#!/bin/bash
set -euo pipefail

# =============================================================================
# DEPENDÊNCIAS DE BUILD — build-essential + base p/ compilar/baixar  (Ubuntu)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  build-essential
  curl
  ca-certificates
  git
  pkg-config
)

info "Verificando dependências de build..."
apt_install "${PACKAGES[@]}"

ok "Setup de build-essential concluído."
