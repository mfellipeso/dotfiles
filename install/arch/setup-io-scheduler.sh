#!/bin/bash
set -euo pipefail

# =============================================================================
# SCHEDULER DE I/O via udev
#   adios disponível  -> HDD bfq | SSD adios | NVMe adios
#   adios indisponível -> HDD bfq | SSD bfq  | NVMe kyber
# =============================================================================
IOSCHED_FILE="/etc/udev/rules.d/60-ioschedulers.rules"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- Detectar adios -----------------------------------------------------------
adios_available=0
for sched in /sys/block/*/queue/scheduler; do
  [[ -r "$sched" ]] || continue
  if grep -qw 'adios' "$sched"; then
    adios_available=1
    break
  fi
done

if (( adios_available )); then
  ssd_sched="adios"
  nvme_sched="adios"
  ok "adios disponível — usando adios para SSD e NVMe"
else
  ssd_sched="bfq"
  nvme_sched="kyber"
  skipped "adios indisponível — fallback: SSD=bfq, NVMe=kyber"
fi

# --- Montar regras ------------------------------------------------------------
IOSCHED_RULES="$(cat <<EOF
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \\
    ATTR{queue/scheduler}="bfq"

# SSD SATA / eMMC
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \\
    ATTR{queue/scheduler}="$ssd_sched"

# NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \\
    ATTR{queue/scheduler}="$nvme_sched"
EOF
)"

# --- Aplicar ------------------------------------------------------------------
info "Configurando scheduler de I/O..."
current="$(cat "$IOSCHED_FILE" 2>/dev/null || echo "")"
if [[ "$current" == "$IOSCHED_RULES" ]]; then
  skipped "$IOSCHED_FILE já está atualizado"
else
  sudo mkdir -p "$(dirname "$IOSCHED_FILE")"
  echo "$IOSCHED_RULES" | sudo tee "$IOSCHED_FILE" > /dev/null
  ok "Regras udev gravadas em $IOSCHED_FILE"

  info "Recarregando regras do udev..."
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ok "Regras udev aplicadas"
fi

ok "Setup do I/O scheduler concluído."
