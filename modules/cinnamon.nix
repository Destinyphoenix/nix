{ pkgs, username, ... }:

# Sway als Compositor auf System-Ebene – ersetzt Hyprland.
# Die Konfiguration (Keybindings, Idle, Lock) liegt in hm-modules/sway.nix.
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";
}
