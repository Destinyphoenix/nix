{ pkgs, username, ... }:

# Sway als Compositor auf System-Ebene – ersetzt Hyprland.
# Die Konfiguration (Keybindings, Idle, Lock) liegt in hm-modules/sway.nix.
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # wlroots-Portals (Bildschirmfreigabe, Datei-Dialoge).
  # Ersetzt die xdg-desktop-portal-hyprland-Konfiguration.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  fonts.packages = [
    pkgs.font-awesome
    pkgs.nerd-fonts.jetbrains-mono
  ];

  security.polkit.enable = true;

  # PAM zum Entsperren:
  # - swaylock wird durch programs.sway.enable automatisch eingerichtet,
  #   ein eigener Eintrag ist NICHT nötig.
  # - hyprlock nur, falls du hm-modules/hyprlock.nix weiter nutzt:
  #     security.pam.services.hyprlock = { };
  # - waylock zum Testen (siehe home.packages in hm-modules/sway.nix):
  #     security.pam.services.waylock = { };

  # ddcutil (SUPER+ALT+Hoch/Runter) braucht i2c-Zugriff:
  # legt die Gruppe 'i2c' an, lädt i2c-dev und setzt die udev-Regeln.
  hardware.i2c.enable = true;
  users.users.${username}.extraGroups = [ "i2c" ];
}
