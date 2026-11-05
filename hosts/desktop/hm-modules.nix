[
  # ../../hm-modules/dark-mode.nix

  ../../hm-modules/sway/displays.nix

  ../../hm-modules/LaTex/latex.nix
  ../../hm-modules/sway/protonvpn.nix
  #../../hm-modules/pass.nix
  # {
  #   terminal.enable = false;
  # }
  (
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        steam
        traceroute
        inetutils # telnet-Client (nur Client, kein telnetd)
        ncdu
        libreoffice
        super-productivity
      ];
    }
  )
]
