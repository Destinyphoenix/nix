# Tofi — Wayland dmenu/launcher.
#
# Home Manager has no native `programs.tofi` module, so the config file is
# written directly to ~/.config/tofi/config via xdg.configFile.
#
# Launched from Hyprland with:  tofi-drun --drun-launch=true
#
# Zwei Configs, beide aus dem Phoenix-Ember-Theme (theme.nix) gespeist, damit
# Launcher und WLAN-Picker farblich zu Bar/Terminal passen:
#   tofi/config  – drun-Launcher (Mod4+r)
#   tofi/network – WLAN-Picker (networkmanager_dmenu --config, Mod4+n)
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

  # WLAN-Picker-Theme (wird von networkmanager_dmenu via --config geladen).
  # Gleiche Palette wie oben, nur größeres Fenster für mehr Netzwerke/Details.
  xdg.configFile."tofi/network".text = ''
    # --- Font ---------------------------------------------------------
    font      = ${theme.font}
    font-size = ${toString theme.fontSize}

    # --- Verhalten ----------------------------------------------------
    ascii-input        = true
    hint-font          = false
    late-keyboard-init = true
    hide-cursor        = true
    num-results        = 8
    prompt-text        = "📶 "

    # --- Phoenix Ember --------------------------------------------------
    # background-color trägt einen Alpha-Kanal (RRGGBBAA), analog zu
    # background_opacity = 0.8 in kitty.nix.
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
}
