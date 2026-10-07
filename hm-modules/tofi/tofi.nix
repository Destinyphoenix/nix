# Tofi — Wayland dmenu/launcher.
#
# Home Manager has no native `programs.tofi` module, so the config file is
# written directly to ~/.config/tofi/config via xdg.configFile.
#
# Aufruf: tofi-drun --drun-launch=true (Mod4+r in hm-sway.nix)
#
# Hier nur Paket + Launcher-Config (tofi/config). Jeder weitere tofi-Screen
# bringt sein eigenes Theme im jeweiligen Modul mit (Muster: websearch.nix):
#   network.nix    – tofi/network (WLAN-Picker via networkmanager_dmenu)
#   bluetooth.nix  – tofi/bluetooth
#   audio.nix      – tofi/audio, tofi/mic, tofi/video
#   calculator.nix – tofi/calculator
#   websearch.nix  – tofi/websearch
{ pkgs, theme, ... }:

{

  home.packages = [
    pkgs.tofi
    # Nerd-Font (theme.font) kommt bereits systemweit aus modules/sway.nix
    # (fonts.packages -> pkgs.nerd-fonts.jetbrains-mono). Kein weiteres
    # Font-Paket hier nötig.
  ];

  xdg.configFile."tofi/config".text = ''
    # --- Font -----------------------------------------------------------
    # Pango backend: Family-Name reicht, solange fonts.fontconfig.enable
    # gesetzt ist. `hint-font` wirkt nur beim Harfbuzz-Backend, hier egal.
    font      = ${theme.font}
    font-size = ${toString theme.fontSize}

    # --- Input / Verhalten ------------------------------------------------
    ascii-input        = true
    hint-font          = false
    late-keyboard-init = true
    hide-cursor        = true
    num-results        = 6
    prompt-text        = "❯ "

    # --- Phoenix Ember -------------------------------------------------
    # background-color trägt einen Alpha-Kanal (RRGGBBAA). CC ~ 80% Deckkraft,
    # gleicher Wert wie background_opacity = 0.8 in kitty.nix.
    corner-radius     = 14
    outline-width     = 2
    outline-color     = ${theme.primary}
    border-width      = 1
    border-color      = ${theme.border}
    background-color  = ${theme.background}CC

    text-color            = ${theme.muted}
    prompt-color          = ${theme.primary}
    input-color           = ${theme.foreground}
    placeholder-color     = ${theme.muted}
    default-result-color  = ${theme.muted}

    # ausgewählte Zeile: heller Ember-Balken, dunkler Text für Kontrast
    selection-color                    = ${theme.background}
    selection-match-color              = ${theme.surface}
    selection-background               = ${theme.primary}
    selection-background-padding       = 6
    selection-background-corner-radius = 8
    result-spacing                     = 4

    # --- Größe ------------------------------------------------------------
    width  = 560
    height = 320
  '';
}
