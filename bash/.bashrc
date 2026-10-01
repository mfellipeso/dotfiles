# ~/.bashrc — gerenciado via stow (dotfiles/bash). Estilo Omarchy, num arquivo só.
[[ $- != *i* ]] && return

export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac

# History
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE=$HISTSIZE

# Completion: Tab cicla pelas opções, setas buscam no histórico
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'TAB: menu-complete'
bind '"\e[Z": menu-complete-backward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Ferramentas
command -v mise &>/dev/null && eval "$(mise activate bash)"
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash --cmd cd)"
[[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash

# Aliases pessoais (pacote stow `aliases`)
[[ -f ~/.aliases ]] && source ~/.aliases
