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

    "$bt" show | grep -q "Powered: yes" || "$bt" power on >/dev/null

    # "devices" (nicht "devices Paired") zeigt auch frisch gescannte,
    # noch nicht gepairte Geräte an.
    # Seit bluez 5.87 färbt bluetoothctl auch ohne TTY (ANSI-Codes) und
    # mischt während eines laufenden Scans [CHG]/[NEW]/[DEL]-Events in die
    # Ausgabe. Daher: Farbcodes entfernen und nur echte "Device <MAC> <Name>"-
    # Zeilen übernehmen.
    mapfile -t devices < <(
      "$bt" devices \
        | sed -E 's/\x1b\[[0-9;]*m//g' \
        | grep -E '^Device ([0-9A-F]{2}:){5}[0-9A-F]{2} ' \
        | cut -d' ' -f2- \
        | sort -u
    )

    menu=""
    declare -A mac_of
    for d in "''${devices[@]}"; do
      mac="''${d%% *}"
      name="''${d#* }"
      # Namenlose Geräte (Name == MAC mit Bindestrichen, meist zufällige
      # BLE-Adressen) überspringen – sonst hunderte Einträge und je ein
      # langsamer "info"-Aufruf.
      [ "$name" = "''${mac//:/-}" ] && continue
      info="$("$bt" info "$mac" 2>/dev/null)" || continue
      if grep -qE '^\s+Connected: yes' <<< "$info"; then
        line="✔ $name"
      elif grep -qE '^\s+Paired: yes' <<< "$info"; then
        line="  $name"
      else
        line="+ $name"
      fi
      mac_of["$line"]="$mac"
      menu+="$line"$'\n'
    done
    menu+="⟳ Scan (10s)"

    choice=$(printf '%s' "$menu" | "$tofi" --config "$HOME/.config/tofi/bluetooth")
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
