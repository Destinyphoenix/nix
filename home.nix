{ ... }:

{
  imports = [
    # ./hm-modules/hyprland.nix
    # ./hm-modules/waybar.nix
    ./hm-modules/tofi.nix
    ./hm-modules/git.nix
    ./hm-modules/zed.nix
    ./hm-modules/brave.nix
    ./hm-modules/sway/hm-sway.nix
    ./hm-modules/terminal.nix
    ./hm-modules/wallpaper.nix
    #./hm-modules/fish.nix
    # ./hm-modules/starship.nix
    #  ./hm-modules/kitty.nix
    # ./hm-modules/nvim.nix
    #   ./hm-modules/packages.nix
    #  ./hm-modules/doom.nix
  ];

  home.username = "phoenix";
  home.homeDirectory = "/home/phoenix";
  home.stateVersion = "26.05";
}
