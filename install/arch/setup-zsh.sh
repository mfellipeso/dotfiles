#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO ZSH + PLUGINS + POWERLEVEL10K + FZF + ALIASES
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-theme-powerlevel10k
  vte-common
  fzf
  stow
)

PLUGINS_BLOCK='# Zsh Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme'

VTE_BLOCK='# Open new terminal tabs/windows in the same directory
[[ -f /etc/profile.d/vte.sh ]] && source /etc/profile.d/vte.sh'

FZF_BLOCK='# Set up fzf key bindings
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory'

HG_ALIAS='alias hg='"'"'print -z $(fc -l 1 | fzf --tac --no-sort | sed "s/ *[0-9]* *//")'"'"''

ALIASES_LINE='# Aliases
[[ ! -f ~/.aliases ]] || source ~/.aliases'

KEYBINDINGS_BLOCK='# Ctrl+Left / Ctrl+Right -> jump words
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^H"      backward-kill-word'

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes do zsh..."
pacman_install "${PACKAGES[@]}"

# --- 2. Definir zsh como shell padrão ----------------------------------------
info "Verificando shell padrão..."
if [[ "$SHELL" == "$(command -v zsh)" ]]; then
  skipped "zsh já é o shell padrão"
else
  chsh -s "$(command -v zsh)"
  ok "zsh definido como shell padrão (efetivo no próximo login)"
fi

# --- 3. Blocos no .zshrc ------------------------------------------------------
zshrc_append 'powerlevel10k.zsh-theme'    "$PLUGINS_BLOCK"
zshrc_append 'compinit'                   $'\nautoload -Uz compinit && compinit'
zshrc_append 'vte.sh'                     "$VTE_BLOCK"
zshrc_append 'source <(fzf --zsh)'        "$FZF_BLOCK"
zshrc_append 'alias hg='                  "$HG_ALIAS"
zshrc_append '"^[[1;5D" backward-word'    "$KEYBINDINGS_BLOCK"

# --- 4. Stow + source de aliases ---------------------------------------------
info "Verificando symlink de aliases..."
if [[ -L "$HOME/.aliases" && "$(readlink "$HOME/.aliases")" == *dotfiles/configs/aliases/.aliases* ]]; then
  skipped ".aliases já linkado"
else
  stow_pkg aliases
  ok ".aliases linkado via stow"
fi

zshrc_append 'source ~/.aliases' "$ALIASES_LINE"

ok "Setup do zsh concluído."
