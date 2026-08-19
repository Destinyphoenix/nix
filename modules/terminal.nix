{ pkgs, username, ... }:

# System-Ebene fürs Terminal: aktiviert Fish nur als Shell (Paket +
# /etc/shells-Eintrag, macht programs.fish.enable automatisch) und setzt sie
# als Login-Shell. Die eigentliche Konfiguration (Aliase, Starship-Prompt)
# liegt auf HM-Ebene in hm-modules/hm-terminal.nix.
{
  programs.fish.enable = true;

  users.users.${username}.shell = pkgs.fish;
}
