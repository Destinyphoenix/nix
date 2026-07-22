{ ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;   # run X11 apps under Hyprland
  };

  # tell Electron/Chromium apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
