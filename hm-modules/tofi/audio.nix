# Geräte-Picker — tofi-dmenu-Screens für PipeWire-Default-Devices.
#
# Ein generischer Picker (mkTofiPicker), dreifach instanziiert:
#   tofi-audio-output → Audio/Sinks    (Lautsprecher, Kopfhörer, HDMI/DP)
#   tofi-audio-input  → Audio/Sources  (Mikrofon)
#   tofi-video-input  → Video/Sources  (Webcam)
#
# Alle drei parsen denselben `wpctl status`-Output, daher ein Nix-Modul statt
# dreier Kopien. Analog zu tofi-bluetooth.nix (bluetoothctl statt wpctl).
#
# ● = aktueller Default · (Leerzeichen) = verfügbares Gerät
#
# Aufruf: tofi-audio-output / tofi-audio-input / tofi-video-input
# (gebunden auf Mod4+Shift+a / Mod4+Shift+m / Mod4+Shift+v in hm-sway.nix)
#
# Die Themes tofi/audio, tofi/mic und tofi/video werden ebenfalls hier aus
# derselben Picker-Liste erzeugt (mkTofiTheme) – sie unterscheiden sich nur
# im Prompt-Icon.
{
  pkgs,
  lib,
  theme,
  ...
}:

let
  # Gemeinsames Theme der drei Geräte-Picker (Muster: websearch.nix).
  mkTofiTheme = promptIcon: ''
    # --- Font ---------------------------------------------------------
    font      = ${theme.font}
    font-size = ${toString theme.fontSize}

    # --- Verhalten ----------------------------------------------------
    ascii-input        = true
    hint-font          = false
    late-keyboard-init = true
    hide-cursor        = true
    num-results        = 8
    prompt-text        = "${promptIcon} "

    # --- Phoenix Ember --------------------------------------------------
    background-color = ${theme.background}CC
    outline-width    = 2
    outline-color    = ${theme.primary}
    border-width     = 1
    border-color     = ${theme.border}
    corner-radius     = 10
    width            = 620
    height           = 440
    padding-top      = 20
    padding-bottom   = 20
    padding-left     = 24
    padding-right    = 24

    # --- Text -----------------------------------------------------------
    text-color            = ${theme.muted}
    prompt-color          = ${theme.primary}
    input-color           = ${theme.foreground}
    placeholder-color     = ${theme.muted}
    default-result-color  = ${theme.muted}

    # --- Auswahl (Ember-Balken, wie im Launcher) ------------------------
    selection-color                    = ${theme.background}
    selection-match-color              = ${theme.surface}
    selection-background               = ${theme.primary}
    selection-background-padding       = 6
    selection-background-corner-radius = 4
    result-spacing                     = 8
  '';

  mkTofiPicker =
    {
      name, # Binary-Name, z.B. "tofi-audio-output"
      section, # Top-Level-Block in `wpctl status`: "Audio" oder "Video"
      subsection, # Geräteliste innerhalb der Section: "Sinks:" oder "Sources:"
      tofiConfig, # Dateiname unter ~/.config/tofi/ (Theme via mkTofiTheme)
      label, # Titel für die notify-send-Bestätigung
      ... # promptIcon: Icon vor dem Prompt-Text, nur für mkTofiTheme
    }:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      wpctl="${pkgs.wireplumber}/bin/wpctl"
      tofi="${pkgs.tofi}/bin/tofi"
      notify="${pkgs.libnotify}/bin/notify-send"

      # Nur den Abschnitt zwischen "${section}" -> "${subsection}" und dem
      # nächsten Abschnitts-Header (Sinks/Sources/Filters/Streams/Leerzeile)
      # herausschneiden - Sinks und Sources laufen ohne Leerzeile ineinander,
      # deshalb reicht ein Blankline-Check allein nicht.
      mapfile -t lines < <(
        "$wpctl" status \
          | awk '
              /^${section}$/ { a=1 }
              a && /${subsection}/ { s=1; next }
              s && (/Sinks:/ || /Sources:/ || /Filters:/ || /Streams:/ || /^$/) { exit }
              s { print }
            ' \
          | grep -E '[0-9]+\.' \
          | sed -E 's/^[│ ]*//'
      )

      menu=""
      declare -A id_of
      for l in "''${lines[@]}"; do
        default=false
        [[ "$l" == \** ]] && default=true

        # ID und Name extrahieren; alles ab der ersten "[" abschneiden
        # (deckt sowohl "[vol: 0.40]" bei Audio als auch z.B. "[vc]" bei
        # Video-Quellen ab).
        rest="''${l#\* }"
        id="''${rest%%.*}"
        id="''${id// /}"
        devname="''${rest#*. }"
        devname="''${devname%%\[*}"
        devname="$(sed -E 's/[[:space:]]+$//' <<< "$devname")"

        if $default; then
          line="● $devname"
        else
          line="  $devname"
        fi
        id_of["$line"]="$id"
        menu+="$line"$'\n'
      done

      if [ -z "$menu" ]; then
        "$notify" "${label}" "Keine Geräte gefunden" || true
        exit 0
      fi

      choice=$(printf '%s' "$menu" | "$tofi" --config "$HOME/.config/tofi/${tofiConfig}")
      [ -z "$choice" ] && exit 0

      id="''${id_of[$choice]}"
      "$wpctl" set-default "$id"
      chosen="''${choice#? }"
      "$notify" "${label}" "Aktiv: $chosen" || true
    '';

  pickers = [
    {
      name = "tofi-audio-output";
      section = "Audio";
      subsection = "Sinks:";
      tofiConfig = "audio";
      promptIcon = "󰕾";
      label = "Audioausgabe";
    }
    {
      name = "tofi-audio-input";
      section = "Audio";
      subsection = "Sources:";
      tofiConfig = "mic";
      promptIcon = "󰍬";
      label = "Mikrofon";
    }
    {
      name = "tofi-video-input";
      section = "Video";
      subsection = "Sources:";
      tofiConfig = "video";
      promptIcon = "󰄀";
      label = "Kamera";
    }
  ];
in
{
  home.packages = map mkTofiPicker pickers ++ [ pkgs.libnotify ];

  xdg.configFile = lib.listToAttrs (
    map (p: lib.nameValuePair "tofi/${p.tofiConfig}" { text = mkTofiTheme p.promptIcon; }) pickers
  );
}
