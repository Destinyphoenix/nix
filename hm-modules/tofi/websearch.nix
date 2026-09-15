# Web-Suche — tofi-dmenu-Screen für schnelle Suchanfragen im Browser.
#
# Freitext-Eingabe (require-match=false, leere stdin), analog zu
# tofi-calculator.nix. Eingabe wird URL-encodiert und an Brave als
# Google-Suche übergeben; läuft Brave bereits, öffnet sich ein neuer Tab
# im bestehenden Fenster, sonst startet Brave direkt mit der Ergebnisseite.
#
# Aufruf: tofi-websearch
# (analog zu den Geräte-Pickern noch in hm-sway.nix zu binden, z.B. Mod4+s)
{ pkgs, theme, ... }:

let
  tofi-websearch = pkgs.writeShellScriptBin "tofi-websearch" ''
    set -euo pipefail
    tofi="${pkgs.tofi}/bin/tofi"
    jq="${pkgs.jq}/bin/jq"

    query=$(printf "" | "$tofi" \
      --config "$HOME/.config/tofi/websearch" \
      --require-match=false \
      --prompt-text "󰍉 ")
    [ -z "$query" ] && exit 0

    encoded=$("$jq" -sRr '@uri' <<< "$query")
    setsid -f brave "https://search.brave.com/search?q=$encoded" >/dev/null 2>&1
  '';
in
{
  home.packages = [
    tofi-websearch
    pkgs.jq
  ];

  # Eigenes Theme, analog zu tofi/audio, tofi/mic etc. in tofi.nix — hier
  # separat gehalten, kann bei Bedarf dorthin verschoben werden.
  xdg.configFile."tofi/websearch".text = ''
    # --- Font -----------------------------------------------------------
    font      = ${theme.font}
    font-size = ${toString theme.fontSize}

    # --- Verhalten ----------------------------------------------------
    ascii-input        = true
    hint-font          = false
    late-keyboard-init = true
    hide-cursor        = true
    num-results        = 0
    prompt-text        = "󰍉 "

    # --- Phoenix Ember --------------------------------------------------
    background-color = ${theme.background}CC
    outline-width    = 2
    outline-color    = ${theme.primary}
    border-width     = 1
    border-color     = ${theme.border}
    corner-radius     = 14
    width            = 560
    height           = 100
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
