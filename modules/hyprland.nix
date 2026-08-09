{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # run X11 apps under Hyprland
  };
  services.hypridle.enable = false;
  programs.hyprlock.enable = false;
  programs.waybar.enable = false;

  # tell Electron/Chromium apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kitty
    nautilus
    tofi
    hyprshot
  ];
}
