{ pkgs, theme, ... }:

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
      nire = "sudo nixos-rebuild switch --flake ~/nixos#phoenix";
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
    enableFishIntegration = true;

    settings = {
      add_newline = true;

      character = {
        success_symbol = "[➜](bold ${theme.success})";
        error_symbol = "[✖](bold ${theme.error})";
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
        style = "bold ${theme.info}";
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
      name = theme.font;
      size = theme.fontSize;
    };

    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";

      background = theme.background;
      foreground = theme.foreground;
      cursor = theme.primary;
      cursor_text_color = theme.background;

      selection_background = theme.surface;
      selection_foreground = theme.foreground;

      url_color = theme.warning;

      # --- ANSI 0-7 ---
      color0 = theme.background;
      color1 = theme.error;
      color2 = theme.success;
      color3 = theme.warning;
      color4 = theme.info;
      color5 = "#b3552e"; # magenta -> burnt sienna (kein Kern-Token, nur ANSI-Ergänzung)
      color6 = "#4f8a80"; # cyan -> gedämpftes Teal (kein Kern-Token, nur ANSI-Ergänzung)
      color7 = "#cfc3b8";

      # --- ANSI 8-15 (bright) ---
      color8 = theme.border;
      color9 = theme.primary;
      color10 = "#b3c17a";
      color11 = "#ffd97a";
      color12 = "#6f93b8";
      color13 = "#d97a4d";
      color14 = "#74b0a5";
      color15 = theme.foreground;

      scrollback_lines = 10000;
      cursor_shape = "beam";
      window_padding_width = 6;
      confirm_os_window_close = 0;
      background_opacity = "0.8";
    };
  };
}
