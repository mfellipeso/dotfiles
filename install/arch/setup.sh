#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# OTIMIZAÇÕES DO ARCH — puladas no CachyOS (que já vem otimizado de fábrica).
# No CachyOS, se quiser, rode manualmente: ./setup-sysctl.sh
# =============================================================================
ARCH_OPTIMIZATIONS=(
  setup-sysctl.sh          # vm.swappiness, dirty bytes, etc.
  setup-io-scheduler.sh    # udev rules (bfq/adios/kyber)
)

# =============================================================================
# SCRIPTS DE SETUP — adicione novos scripts aqui em ordem de execução
# =============================================================================
SETUP_SCRIPTS=(
  # 1) Sistema
  setup-system-services.sh           # bluetooth, power-profiles, disable arch-update
  fix-k380-bluetooth-disconnect.sh   # UPower NoPollBatteries (K380 desconectando)

  # 2) Pacotes base
  setup-packages.sh
  setup-aur.sh

  # 3) Shell e ferramentas
  setup-bash.sh          # bash + starship no estilo Omarchy (stow)
  setup-shell-tools.sh   # nano-syntax
  setup-mise.sh          # mise + tools do mise/config.toml (node, claude, codex, herdr)
  setup-herdr.sh         # precisa do mise
  setup-nvim.sh          # neovim (LazyVim) + lazygit

  # 4) Rede e segurança
  setup-ufw.sh
  setup-tailscale.sh     # precisa do ufw (libera tailscale0)
  setup-dns.sh           # interativo
  setup-l2tp.sh

  # 5) Containers / VMs
  setup-docker.sh
  setup-virt.sh          # precisa do ufw (regra de roteamento)

  # 6) Apps
  setup-flatpaks.sh      # flathub (escopo usuário)
)
# =============================================================================

# =============================================================================
# GNOME — só oferecidos se a sessão atual for GNOME; rodam depois de tudo.
# =============================================================================
GNOME_SCRIPTS=(
  setup-gnome-apps.sh          # ptyxis, appindicator, Extension Manager
  setup-gnome-keybindings.sh   # atalho do gradia (flatpak)
  setup-gnome-weather.sh
  setup-gnome-theme.sh         # adw-gtk3 + dark (precisa do flathub)
)
# =============================================================================

source "$SCRIPT_DIR/lib/common.sh"

if grep -qx 'ID=cachyos' /etc/os-release 2>/dev/null; then
  skipped "CachyOS detectado — otimizações do Arch puladas (${ARCH_OPTIMIZATIONS[*]})"
  echo ""
else
  SETUP_SCRIPTS=("${ARCH_OPTIMIZATIONS[@]}" "${SETUP_SCRIPTS[@]}")
fi

if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]]; then
  SETUP_SCRIPTS+=("${GNOME_SCRIPTS[@]}")
else
  skipped "sessão não é GNOME — scripts do GNOME pulados (${GNOME_SCRIPTS[*]})"
  echo ""
fi

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

  # Cada script roda no próprio processo: variáveis e funções não vazam entre eles.
  if ! bash "$path"; then
    err "$script falhou — abortando (os próximos podem depender dele)"
    exit 1
  fi

  echo -e "${GREEN} $script concluído${RESET}"
  echo ""
done

echo -e "${GREEN}=============================="
echo -e " Setup completo!"
echo -e "==============================${RESET}"
