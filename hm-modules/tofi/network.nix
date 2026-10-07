# WLAN-Picker — tofi-Theme für networkmanager_dmenu.
#
# networkmanager_dmenu selbst (Paket + config.ini mit
# `dmenu_command = tofi --config ~/.config/tofi/network`) wird in
# modules/network.nix eingerichtet; hier liegt nur das zugehörige Theme,
# analog zu websearch.nix.
#
# Aufruf: networkmanager_dmenu (gebunden auf Mod4+n in hm-sway.nix)
{ theme, ... }:

{
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
