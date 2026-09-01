{ username, ... }:

let
  hm = ./../../hm-modules;
in
{

  imports = [
    # hm + "/hyprland.nix"
    # hm + "/waybar.nix"
    (hm + "/tofi/tofi.nix")
    (hm + "/git.nix")
    (hm + "/zed.nix")
    (hm + "/brave.nix")
    (hm + "/sway/hm-sway.nix")
    (hm + "/terminal.nix")
    (hm + "/tofi/bluetooth.nix")
    #./hm-modules/fish.nix
    # ./hm-modules/starship.nix
    #  ./hm-modules/kitty.nix
    # ./hm-modules/nvim.nix
    #   ./hm-modules/packages.nix
    #  ./hm-modules/doom.nix
  ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
}
