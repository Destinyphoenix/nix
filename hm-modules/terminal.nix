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
      nix_shell = {
        disabled = false;
        format = "via [❄️ $state( \\($name\\))](bold blue) ";
      };
      cmd_duration.min_time = 2000; # ms
    };
  };

  # Für propa/pco/pdis: die alte config.fish ging davon aus, dass diese
  # Binaries schon auf dem System sind. Nixpkgs-Namen verifiziert:

  # Kitty als Terminal – wird von hm-sway.nix per `terminal = "kitty"` und
  # `Mod4+q` aufgerufen. Theme (gruvbox-dark) und Font (JetBrainsMono Nerd
  # Font) matchen die i3status-rust-Bar aus hm-sway.nix.

  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    themeFile = "gruvbox-dark";

    # Fish als Kitty-interne Shell – ersetzt users.users.phoenix.shell auf
    # NixOS-Ebene (siehe letzte Antwort, Option A). Fish muss nicht die
    # Login-Shell sein, kitty startet sie direkt.
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";

      scrollback_lines = 10000;
      cursor_shape = "beam";
      window_padding_width = 6;
      confirm_os_window_close = 0;
      background_opacity = "0.8";

      # Für Screenshare/Portale ggf. relevant, falls du remote control brauchst:
      # allow_remote_control = "socket-only";
      # listen_on = "unix:/tmp/kitty";
    };
  };
}
