#!/bin/bash
set -euo pipefail

# =============================================================================
# INSTALAÇÃO DO GO (release oficial em /usr/local/go)  (Ubuntu)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

GO_PREFIX='/usr/local/go'
GO_BIN="$GO_PREFIX/bin/go"

PATH_MARKER="$GO_PREFIX/bin"
PATH_BLOCK='# Go
export PATH=$PATH:'"$GO_PREFIX"'/bin'

# --- 1. Instalação do binário -------------------------------------------------
info "Verificando go em $GO_PREFIX..."
if [[ -x "$GO_BIN" ]]; then
  skipped "go já instalado ($("$GO_BIN" version)) — remova $GO_PREFIX para reinstalar"
else
  need_cmd curl || _finish 1

  case "$(dpkg --print-architecture)" in
    amd64) go_arch='amd64' ;;
    arm64) go_arch='arm64' ;;
    armhf) go_arch='armv6l' ;;
    i386)  go_arch='386' ;;
    *) err "arquitetura não suportada: $(dpkg --print-architecture)"; _finish 1 ;;
  esac

  # Versão latest estável (override: GO_VERSION=go1.26.3 ./setup-golang.sh)
  go_version="${GO_VERSION:-$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)}"
  tarball="${go_version}.linux-${go_arch}.tar.gz"
  tmp_tarball="$(mktemp -d)/${tarball}"

  info "Baixando ${tarball}..."
  curl -fL -o "$tmp_tarball" "https://go.dev/dl/${tarball}"

  # Nunca extrair sobre uma árvore existente — limpa antes (docs oficiais).
  sudo rm -rf "$GO_PREFIX"
  sudo tar -C /usr/local -xzf "$tmp_tarball"
  rm -f "$tmp_tarball"
  ok "go instalado em $GO_PREFIX ($("$GO_BIN" version))"
fi

# --- 2. PATH no bashrc e zshrc (se existirem) --------------------------------
info "Verificando PATH do go nos rc files..."
rc_append "$PATH_MARKER" "$PATH_BLOCK"

ok "Setup do go concluído."
