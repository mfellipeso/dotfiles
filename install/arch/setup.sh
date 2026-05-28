#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# SCRIPTS DE SETUP — adicione novos scripts aqui em ordem de execução
# =============================================================================
SETUP_SCRIPTS=(
  # 1) Kernel/sistema
  setup-system-services.sh   # bluetooth, power-profiles, disable arch-update
  setup-io-scheduler.sh      # udev rules (bfq/adios)
  setup-sysctl.sh

  # 2) Pacotes base
  setup-packages.sh
  setup-aur.sh

  # 3) Shell
  setup-zsh.sh
  setup-shell-tools.sh       # zoxide, nano-syntax, nvm

  # 4) Rede e segurança
  setup-ufw.sh
  setup-dns.sh
  setup-l2tp.sh

  # 5) Containers / VMs
  setup-docker.sh
  setup-virt.sh

  # 6) Apps
  setup-ai-clis.sh           # claude, codex, opencode
  setup-flatpaks.sh

  # 7) Desktop environment
  setup-gnome-keybindings.sh
  setup-gnome-weather.sh
  setup-theme.sh
)
# =============================================================================

source "$SCRIPT_DIR/lib/common.sh"

for script in "${SETUP_SCRIPTS[@]}"; do
  path="$SCRIPT_DIR/$script"
  echo -e "${CYAN}==============================${RESET}"
  echo -e "${CYAN} $script${RESET}"
  echo -e "${CYAN}==============================${RESET}"

  if [[ ! -f "$path" ]]; then
    err "$path não encontrado — pulando"
    continue
  fi

  read -r -p "$(echo -e "${CYAN}Executar $script? [s/N] ${RESET}")" answer
  if [[ "${answer,,}" != "s" ]]; then
    skipped "$script pulado"
    echo ""
    continue
  fi

  # shellcheck source=/dev/null
  source "$path"

  echo -e "${GREEN} $script concluído${RESET}"
  echo ""
done

echo -e "${GREEN}=============================="
echo -e " Setup completo!"
echo -e "==============================${RESET}"
