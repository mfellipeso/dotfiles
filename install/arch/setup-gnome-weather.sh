#!/bin/bash
set -euo pipefail

# =============================================================================
# GNOME WEATHER — instalação + adicionar localização via Nominatim
# =============================================================================

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

if ! command -v gsettings &>/dev/null; then
  skipped "gsettings não encontrado — pulando"
  _finish 0
fi

# --- 1. Detectar instalação existente ----------------------------------------
system_weather=0
flatpak_weather=0
command -v gnome-weather &>/dev/null && system_weather=1
flatpak list 2>/dev/null | grep -q "org.gnome.Weather" && flatpak_weather=1

# --- 2. Instalar se faltar ----------------------------------------------------
if [[ $system_weather -eq 0 && $flatpak_weather -eq 0 ]]; then
  read -rp "$(echo -e "${CYAN}GNOME Weather não instalado. Instalar? [pacman/flatpak/N] ${RESET}")" install_choice
  case "${install_choice,,}" in
    pacman|p)
      sudo pacman -S --noconfirm gnome-weather
      ok "gnome-weather instalado via pacman"
      system_weather=1
      ;;
    flatpak|f)
      need_cmd flatpak "rode setup-flatpaks.sh primeiro" || _finish 1
      flatpak install -y flathub org.gnome.Weather
      ok "GNOME Weather instalado via flatpak"
      flatpak_weather=1
      ;;
    *)
      skipped "GNOME Weather pulado"
      _finish 0
      ;;
  esac
fi

# --- 3. Adicionar localização -------------------------------------------------
read -rp "$(echo -e "${CYAN}Adicionar localização ao GNOME Weather? [s/N] ${RESET}")" answer
[[ "${answer,,}" != "s" ]] && { skipped "GNOME Weather pulado"; _finish 0; }

read -rp "Digite o nome da localização (vazio para cancelar): " location_name
[[ -z "$location_name" ]] && { skipped "Localização vazia — cancelado"; _finish 0; }

need_cmd jq "instale com sudo pacman -S jq" || _finish 1
need_cmd bc  "instalando..." || pacman_install bc

info "Buscando '$location_name'..."
query="$(echo "$location_name" | sed 's/ /+/g')"
request=$(curl -s "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1")

if [[ "$request" == "[]" || -z "$request" ]]; then
  err "Nenhuma localização encontrada para '$location_name'"
  _finish 0
fi

display="$(echo "$request" | jq -r '.[0].display_name')"
raw_lat="$(echo "$request" | jq -r '.[0].lat')"
raw_lon="$(echo "$request" | jq -r '.[0].lon')"
name="${display%%,*}"

read -rp "$(echo -e "${CYAN}Adicionar '$display'? [s/N] ${RESET}")" answer
[[ "${answer,,}" != "s" ]] && { skipped "Operação cancelada"; _finish 0; }

# Nominatim retorna graus; gsettings espera radianos
lat=$(echo "$raw_lat / (180 / 3.141592654)" | bc -l)
lon=$(echo "$raw_lon / (180 / 3.141592654)" | bc -l)

location_entry="<(uint32 2, <('$name', '', false, [($lat, $lon)], @a(dd) [])>)>"

apply_location() {
  local label="$1"; shift
  local current
  current="$("$@" get org.gnome.Weather locations)"
  if echo "$current" | grep -qF "'$name'"; then
    skipped "$name já adicionado ($label)"
  elif [[ "$current" == "@av []" ]]; then
    "$@" set org.gnome.Weather locations "[$location_entry]"
    ok "$name adicionado ($label)"
  else
    "$@" set org.gnome.Weather locations "$(echo "$current" | sed "s|>]|>, $location_entry]|")"
    ok "$name adicionado ($label)"
  fi
}

[[ $system_weather  -eq 1 ]] && apply_location "sistema" gsettings
[[ $flatpak_weather -eq 1 ]] && apply_location "flatpak" flatpak run --command=gsettings org.gnome.Weather

ok "Setup do GNOME Weather concluído."
