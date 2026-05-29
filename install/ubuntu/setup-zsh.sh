#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO ZSH + PLUGINS + STARSHIP + FZF + ALIASES  (Ubuntu)
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

PACKAGES=(
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  zoxide
  eza
  stow
  git
  curl
)

STARSHIP_CONFIG="$HOME/.config/starship.toml"

PLUGINS_BLOCK='# Zsh Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

STARSHIP_BLOCK='# Starship prompt
eval "$(starship init zsh)"'

VTE_BLOCK='# Open new terminal tabs/windows in the same directory
[[ -f /etc/profile.d/vte-2.91.sh ]] && source /etc/profile.d/vte-2.91.sh'

# fzf no Ubuntu < 0.48 não tem `fzf --zsh`; usamos os scripts do pacote.
FZF_BLOCK='# Set up fzf key bindings
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh'

HISTORY_BLOCK='# History (bem grande + dedup + compartilhado entre sessões)
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt APPEND_HISTORY        # acrescenta em vez de sobrescrever
setopt SHARE_HISTORY         # compartilha o history entre sessões abertas
setopt EXTENDED_HISTORY      # grava timestamp de cada comando
setopt HIST_IGNORE_ALL_DUPS  # remove duplicatas antigas
setopt HIST_IGNORE_SPACE     # não grava comandos iniciados com espaço
setopt HIST_REDUCE_BLANKS    # normaliza espaços em branco
setopt HIST_FIND_NO_DUPS     # ignora duplicatas ao navegar
# `history` sem args mostra só os últimos 16; isto faz mostrar tudo:
alias history="history 1"'

ZOXIDE_BLOCK='# Zoxide (cd inteligente) — mantenha por último no .zshrc
eval "$(zoxide init zsh --cmd cd)"'

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
apt_install "${PACKAGES[@]}"

# --- 2. Starship --------------------------------------------------------------
info "Verificando starship..."
if command -v starship &>/dev/null; then
  skipped "starship já instalado ($(starship --version | head -n1))"
else
  info "Instalando starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  ok "starship instalado"
fi

# --- 3. Preset catppuccin-powerline (mocha) ----------------------------------
info "Verificando preset do starship..."
mkdir -p "$(dirname "$STARSHIP_CONFIG")"
if [[ -f "$STARSHIP_CONFIG" ]]; then
  skipped "starship.toml já existe em $STARSHIP_CONFIG (preservando customizações)"
else
  starship preset catppuccin-powerline -o "$STARSHIP_CONFIG"
  # Mocha já é o padrão do preset, mas garantimos explicitamente.
  sed -i "s/^palette = .*/palette = 'catppuccin_mocha'/" "$STARSHIP_CONFIG"
  ok "starship.toml gerado em $STARSHIP_CONFIG (catppuccin-powerline, mocha)"
fi

# --- 4. Definir zsh como shell padrão ----------------------------------------
info "Verificando shell padrão..."
if [[ "$SHELL" == "$(command -v zsh)" ]]; then
  skipped "zsh já é o shell padrão"
else
  chsh -s "$(command -v zsh)"
  ok "zsh definido como shell padrão (efetivo no próximo login)"
fi

# --- 5. Blocos no .zshrc ------------------------------------------------------
zshrc_append 'zsh-autosuggestions.zsh'        "$PLUGINS_BLOCK"
zshrc_append 'compinit'                       $'\nautoload -Uz compinit && compinit'
zshrc_append 'starship init zsh'              "$STARSHIP_BLOCK"
zshrc_append 'vte-2.91.sh'                    "$VTE_BLOCK"
zshrc_append 'fzf/examples/key-bindings.zsh'  "$FZF_BLOCK"
zshrc_append 'HIST_IGNORE_ALL_DUPS'           "$HISTORY_BLOCK"
zshrc_append 'alias hg='                      "$HG_ALIAS"
zshrc_append '"^[[1;5D" backward-word'        "$KEYBINDINGS_BLOCK"

# --- 6. Stow + source de aliases ---------------------------------------------
info "Verificando symlink de aliases..."
if [[ -L "$HOME/.aliases" && "$(readlink "$HOME/.aliases")" == *dotfiles/aliases/.aliases* ]]; then
  skipped ".aliases já linkado"
else
  stow_pkg aliases
  ok ".aliases linkado via stow"
fi

zshrc_append 'source ~/.aliases' "$ALIASES_LINE"

# Zoxide por último para silenciar o aviso do `zoxide doctor`.
zshrc_append 'zoxide init zsh' "$ZOXIDE_BLOCK"

ok "Setup do zsh concluído."
