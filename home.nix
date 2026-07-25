{ ... }:

{
  imports = [
   # ./hm-modules/hyprland.nix
   # ./hm-modules/waybar.nix
    ./hm-modules/tofi.nix
  #  ./hm-modules/rofi.nix       # installed but unused (your menu is tofi)
   # ./hm-modules/zed.nix
    #./hm-modules/fish.nix
 #   ./hm-modules/starship.nix
  #  ./hm-modules/kitty.nix
   # ./hm-modules/nvim.nix
 #   ./hm-modules/packages.nix
  #  ./hm-modules/doom.nix
  ];

  home.username = "phoenix";
  home.homeDirectory = "/home/phoenix";
  home.stateVersion = "26.05";
}
