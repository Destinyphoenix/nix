# Bluetooth-Picker — kompakter tofi-dmenu-Screen für Connect/Disconnect/Pair/Scan.
#
# Nutzt bluetoothctl direkt statt rofi-bluetooth/bluetuith.
# ✔ = verbunden · (Leerzeichen) = gepaart, nicht verbunden · + = neu gefunden, ungepaart
#
# Aufruf: tofi-bluetooth  (gebunden auf Mod4+Shift+b in hm-sway.nix)
{ pkgs, ... }:

let
  tofi-bluetooth = pkgs.writeShellScriptBin "tofi-bluetooth" ''
    set -euo pipefail
    bt=${pkgs.bluez}/bin/bluetoothctl
    tofi=${pkgs.tofi}/bin/tofi
    notify=${pkgs.libnotify}/bin/notify-send

    "$bt" show | grep -q "Powered: yes" || "$bt" power on

    # "devices" (nicht "devices Paired") zeigt auch frisch gescannte,
    # noch nicht gepairte Geräte an.
    mapfile -t devices < <("$bt" devices | cut -d' ' -f2-)

    menu=""
    declare -A mac_of
    for d in "''${devices[@]}"; do
      mac="''${d%% *}"
      name="''${d#* }"
      info="$("$bt" info "$mac")"
      if grep -q "Connected: yes" <<< "$info"; then
        line="✔ $name"
      elif grep -q "Paired: yes" <<< "$info"; then
        line="  $name"
      else
        line="+ $name"
      fi
      mac_of["$line"]="$mac"
      menu+="$line"$'\n'
    done
    menu+="⟳ Scan (10s)"

    choice=$(printf '%s' "$menu" | "$tofi" --config "$HOME/.config/tofi/network" --prompt-text "  ")
    [ -z "$choice" ] && exit 0

    if [ "$choice" = "⟳ Scan (10s)" ]; then
      # Läuft synchron 10s; das tofi-Fenster ist da schon zu, deshalb
      # Notify-Hinweis statt sichtbarem UI-Feedback.
      "$bt" --timeout 10 scan on >/dev/null 2>&1 &
      sleep 1
      exec "$0"
      #"$notify" "Bluetooth" "Scan fertig – tofi-bluetooth erneut öffnen" || true
      #exit 0
    fi

    mac="''${mac_of[$choice]}"
    case "$choice" in
      ✔*) "$bt" disconnect "$mac" ;;
      +*) "$bt" pair "$mac" && "$bt" trust "$mac" && "$bt" connect "$mac" ;;
      *)  "$bt" connect "$mac" ;;
    esac
  '';
in
{
  home.packages = [
    tofi-bluetooth
    pkgs.libnotify
  ];
}
