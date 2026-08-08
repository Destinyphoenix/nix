# modules/zsa.nix
#
# NixOS-layer module: udev rules + plugdev group for ZSA keyboards
# (Moonlander, Voyager, Ergodox EZ, Planck EZ). Lets Oryx web flashing,
# Keymapp, and live-training talk to the keyboard without root.
#
# This is the declarative equivalent of hand-writing
# /etc/udev/rules.d/50-zsa.rules and running usermod -aG plugdev.
{
  pkgs,
  username,
  ...
}:
{
  # Installs pkgs.zsa-udev-rules into services.udev.packages and creates the
  # plugdev group. This ships ZSA's official ruleset (hidraw + WebUSB + Wally /
  # Keymapp DFU rules for all their boards) — the same content you pasted.
  hardware.keyboard.zsa.enable = true;

  # hardware.keyboard.zsa.enable CREATES the plugdev group but does NOT put you
  # in it. Membership is required for the rules to grant you access.
  users.users.${username}.extraGroups = [ "plugdev" ];

  environment.systemPackages = with pkgs; [
    keymapp
  ];
}
