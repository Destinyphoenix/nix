{ ... }:
{

  wayland.windowManager.sway.config.startup = [
    { command = "protonvpn connect --country DE --securecore"; }
  ];
}
