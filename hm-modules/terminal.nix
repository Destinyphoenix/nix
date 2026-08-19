{ pkgs, ... }:

# Fish + Starship gebündelt, da beide eng zusammenhängen (Starship braucht
# die Fish-Integration). 1:1 portiert aus der alten
# dot/.config/fish/config.fish + dot/.config/starship.toml.
{
  programs.fish = {
    enable = true;

    # source /usr/share/cachyos-fish-config/... entfällt – das war
    # CachyOS/Arch-spezifisch und hat auf NixOS keine Entsprechung.
    shellAbbrs = {
      propa = "pass-cli";
      pdis = "protonvpn disconnect";
      pco = "protonvpn connect --country DE --securecore";
    };

    interactiveShellInit = ''
      # export PATH=... aus der alten config.fish, per fish_add_path
      # (idiomatisch für Fish + HM statt manuellem export).
      fish_add_path ~/.local/bin
      fish_add_path ~/.config/emacs/bin
    '';
  };

  # War in der alten config.fish explizit gesetzt (export XDG_CONFIG_HOME).
  # Unter HM i. d. R. bereits Standard, schadet aber nicht, es hier explizit
  # zu haben.
  home.sessionVariables.XDG_CONFIG_HOME = "$HOME/.config";

  programs.starship = {
    enable = true;
    enableFishIntegration = true; # ersetzt `starship init fish | source`

    # 1:1 aus der alten starship.toml.
    settings = {
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
      };

      package.disabled = false;
      git_branch.disabled = false;

      sudo = {
        disabled = false;
        symbol = "🦾 ";
      };

      docker_context = {
        symbol = "🐳 ";
        detect_files = [
          "docker-compose.yml"
          "docker-compose.yaml"
          "Dockerfile"
        ];
        only_with_files = true;
        detect_extensions = [ ];
        detect_folders = [ ];
        style = "blue bold";
        disabled = false;
        format = "via [$symbol$context]($style) ";
      };
    };
  };

  # Für propa/pco/pdis: die alte config.fish ging davon aus, dass diese
  # Binaries schon auf dem System sind. Nixpkgs-Namen verifiziert:
  home.packages = with pkgs; [
    proton-pass-cli
    protonvpn-cli
  ];
}
