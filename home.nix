# home.nix
{ username, homeModules, ... }:

{
  imports = homeModules;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
}
