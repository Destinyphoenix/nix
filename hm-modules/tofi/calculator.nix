# Taschenrechner — tofi-dmenu-Screen für schnelle Berechnungen via qalc.
#
# Kein Kandidaten-Menü, sondern reine Freitext-Eingabe (require-match=false,
# leere stdin). Jede Eingabe wird an `qalc` übergeben; das Ergebnis erscheint
# als Prompt-Präfix der nächsten Zeile, sodass sich Rechnungen verketten
# lassen ("42" -> "42 = " -> "+ 8" -> "50 = " -> ...). Leere Eingabe/Esc
# beendet den Screen.
#
# Aufruf: tofi-calculator
# (analog zu den Geräte-Pickern noch in hm-sway.nix zu binden, z.B. Mod4+c)
{ pkgs, theme, ... }:

let
  tofi-calculator = pkgs.writeShellScriptBin "tofi-calculator" ''
    set -euo pipefail
    tofi="${pkgs.tofi}/bin/tofi"
    qalc="${pkgs.libqalculate}/bin/qalc"

    result=""
    while true; do
      prompt="= "
      [ -n "$result" ] && prompt="$result = "

      input=$(printf "" | "$tofi" \
        --config "$HOME/.config/tofi/calculator" \
        --require-match=false \
        --prompt-text "$prompt")
      [ -z "$input" ] && exit 0

      if ! result=$("$qalc" -t "$input" 2>/dev/null); then
        result="Fehler"
      fi
    done
  '';
in
{
  home.packages = [
    tofi-calculator
    pkgs.libqalculate
  ];

  # Eigenes Theme, analog zu tofi/audio, tofi/mic etc. in tofi.nix — hier
  # separat gehalten, kann bei Bedarf dorthin verschoben werden.
  xdg.configFile."tofi/calculator".text = ''
    # --- Font -----------------------------------------------------------
    font      = ${theme.font}
    font-size = ${toString theme.fontSize}

    # --- Verhalten ----------------------------------------------------
    ascii-input        = true
    hint-font          = false
    late-keyboard-init = true
    hide-cursor        = true
    num-results        = 0
    prompt-text        = "󰃬 "

    # --- Phoenix Ember --------------------------------------------------
    background-color = ${theme.background}CC
    outline-width    = 2
    outline-color    = ${theme.primary}
    border-width     = 1
    border-color     = ${theme.border}
    corner-radius     = 14
    width            = 480
    height           = 120
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

    # --- Auswahl (ungenutzt ohne Kandidatenliste, der Vollständigkeit halber) --
    selection-color                    = ${theme.background}
    selection-match-color              = ${theme.surface}
    selection-background               = ${theme.primary}
    selection-background-padding       = 6
    selection-background-corner-radius = 4
    result-spacing                     = 8
  '';
}
