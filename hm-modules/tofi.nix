# Tofi — Wayland dmenu/launcher.
#
# Home Manager has no native `programs.tofi` module, so the config file is
# written directly to ~/.config/tofi/config via xdg.configFile.
#
# Launched from Hyprland with:  tofi-drun --drun-launch=true
#
# Font note: on Arch you pointed `font` at a .ttf path under /usr/share/fonts.
# That path does not exist on NixOS. Two options below — the default uses the
# Pango backend (font by family name), which is the robust, reproducible choice.
{ pkgs, ... }:

{
  home.packages = [
    pkgs.tofi
    # Provides the "Noto Sans Mono" family referenced below. If you already
    # install Noto elsewhere (a shared fonts module), drop this line.
    pkgs.noto-fonts
  ];

  xdg.configFile."tofi/config".text = ''
    # --- Font ---------------------------------------------------------------
    # Pango backend: reference the family name. Requires the font package
    # installed (above) and fonts.fontconfig.enable = true (already set in
    # your home.nix). `hint-font` is ignored on this backend.
    font = Noto Sans Mono

    # Harfbuzz backend alternative (faster, no font fallback). To use it,
    # comment the line above and point at a real store path, e.g.:
    #   font = ${pkgs.noto-fonts}/share/fonts/noto/NotoSansMono-Regular.ttf
    # Verify the actual filename first — Noto ships variable fonts in current
    # nixpkgs, so it may be NotoSansMono[wdth,wght].ttf. Check with:
    #   ls ${pkgs.noto-fonts}/share/fonts/noto/ | grep -i mono
    # Only with this backend does `hint-font = false` take effect.

    # --- Input / behaviour --------------------------------------------------
    ascii-input       = true
    hint-font         = false
    late-keyboard-init = true
    hide-cursor       = true
    num-results       = 3

    # --- Theme (green-on-black terminal) ------------------------------------
    corner-radius     = 60
    outline-color     = #D3D1B9
    outline-width     = 3
    border-color      = #E3E1C9
    border-width      = 1
    background-color  = #000000
    text-color        = #0A3
    selection-color   = #0F6
    # prompt-text     = "C:\> "

    # --- Size ---------------------------------------------------------------
    width             = 540
    height            = 250
  '';
}
