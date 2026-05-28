#!/bin/bash
set -euo pipefail

# =============================================================================
# CLIs DE IA — Claude Code, Codex, OpenCode
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- 1. Claude Code -----------------------------------------------------------
info "Claude Code..."
if command -v claude &>/dev/null; then
  skipped "claude já instalado ($(claude --version 2>/dev/null || echo 'versão desconhecida'))"
else
  curl -fsSL https://claude.ai/install.sh | bash
  ok "claude instalado"
fi

CLAUDE_BLOCK='# Claude Code
export PATH="$HOME/.local/bin:$PATH"
alias claude='"'"'claude --dangerously-skip-permissions'"'"''
zshrc_append 'dangerously-skip-permissions' "$CLAUDE_BLOCK"

# --- 2. Codex (npm) -----------------------------------------------------------
info "Codex CLI..."
need_cmd npm "rode setup-shell-tools.sh primeiro (nvm)" || _finish 1

if npm list -g @openai/codex &>/dev/null 2>&1; then
  skipped "@openai/codex já instalado ($(codex --version 2>/dev/null || echo 'versão desconhecida'))"
else
  npm i -g @openai/codex
  ok "@openai/codex instalado"
fi

CODEX_BLOCK='# codex
alias codex='"'"'codex --dangerously-bypass-approvals-and-sandbox'"'"''
zshrc_append 'dangerously-bypass-approvals-and-sandbox' "$CODEX_BLOCK"

# --- 3. OpenCode --------------------------------------------------------------
info "OpenCode..."
if command -v opencode &>/dev/null; then
  skipped "opencode já instalado"
else
  curl -fsSL https://opencode.ai/install | bash
  ok "opencode instalado"
fi

if [[ -L "$HOME/.config/opencode" ]]; then
  skipped "config do opencode já linkada"
else
  stow_pkg opencode
  ok "config do opencode linkada via stow"
fi

OPENCODE_BLOCK='# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT=1'
zshrc_append '.opencode/bin' "$OPENCODE_BLOCK"

ok "Setup das CLIs de IA concluído."
