{
  config,
  lib,
  pkgs,
  theme,
  ...
}:
let
  # Alle Elemente auf Bar-Hintergrund, unterschieden wird nur über die Schrift.
  button = text: {
    border = theme.background;
    background = theme.background;
    inherit text;
  };

  # Gemeinsame Basis beider Bars; unterschiedlich sind nur die
  # i3status-rust-Config und die Workspace-Farben.
  bar = cfgName: workspaces: {
    position = "top";
    statusCommand = "${lib.getExe pkgs.i3status-rust} ${config.xdg.configHome}/i3status-rust/config-${cfgName}.toml";
    trayOutput = "none";
    fonts = {
      names = [ theme.font ];
      size = theme.fontSize * 1.0;
    };
    colors = {
      background = theme.background;
      statusline = theme.muted;
      separator = theme.background;
      bindingMode = button theme.warning;
    }
    // workspaces;
  };

  # Ersetzt den kompletten [theme]-Block (HM merged settings nur flach),
  # daher steht "plain" hier und nicht in der `theme`-Option.
  statusTheme = {
    theme = "plain";
    overrides = {
      idle_bg = theme.background;
      idle_fg = theme.muted;
      info_bg = theme.background;
      info_fg = theme.foreground;
      good_bg = theme.background;
      good_fg = theme.muted;
      warning_bg = theme.background;
      warning_fg = theme.warning;
      critical_bg = theme.background;
      critical_fg = theme.error;
      separator = " ";
      separator_bg = "auto";
    };
  };
in
{

  ##########################################################################
  ### Statusleiste (swaybar + i3status-rust)
  ##########################################################################
  wayland.windowManager.sway.config.bars = [
    # Immer sichtbar: nur das Nötigste.
    (bar "default" {
      focusedWorkspace = button theme.primary;
      activeWorkspace = button theme.foreground;
      inactiveWorkspace = button theme.muted;
      urgentWorkspace = button theme.error;
    })

    # Nur solange Super gehalten wird, liegt dann über der minimalen Bar.
    # Workspaces kräftiger, damit man beim Wechseln sofort sieht, wo man ist.
    (
      bar "full" {
        focusedWorkspace = {
          border = theme.primary;
          background = theme.primary;
          text = theme.background;
        };
        activeWorkspace = button theme.primary;
        inactiveWorkspace = button theme.foreground;
        urgentWorkspace = {
          border = theme.error;
          background = theme.error;
          text = theme.background;
        };
      }
      // {
        mode = "hide";
        hiddenState = "hide";
        extraConfig = "modifier Mod4";
      }
    )
  ];

  programs.i3status-rust = {
    enable = true;

    bars.default = {
      icons = "material-nf";
      settings.theme = statusTheme;
      blocks = [
        # Leer, solange weder Mikro, Bildschirm noch Webcam aufgenommen werden.
        {
          block = "privacy";
          driver = [
            { name = "pipewire"; }
            { name = "v4l"; }
          ];
        }
        {
          block = "sound";
          format = " $icon ";
        }
        {
          block = "battery";
          format = " $icon $percentage ";
          full_format = ""; # bei vollem Akku ausblenden
          missing_format = ""; # Desktop ohne Akku
        }
        {
          block = "net";
          format = " $icon ";
          format_alt = " $icon {$ssid|Wired} ";
          interval = 5;
        }
        {
          block = "time";
          interval = 30;
          format = " $timestamp.datetime(f:'%R') ";
        }
      ];
    };

    bars.full = {
      icons = "material-nf";
      settings.theme = statusTheme;
      blocks = [
        {
          block = "temperature";
          interval = 5;
          format = " $icon $max ";
        }
        {
          block = "cpu";
          interval = 2;
        }
        {
          block = "memory";
          format = " $icon $mem_used_percents ";
        }
        { block = "load"; }
        {
          block = "disk_space";
          path = "/";
        }
        # Mikrofon; zeigt nur das Icon, wenn stummgeschaltet.
        {
          block = "sound";
          device_kind = "source";
        }
        { block = "sound"; }
        {
          block = "battery";
          format = " $icon $percentage {$power.eng(w:3) |}{$time_remaining.dur(hms:true, min_unit:m) |}";
          full_format = " $icon $percentage ";
          not_charging_format = " $icon $percentage ";
          missing_format = ""; # Desktop ohne Akku
        }
        {
          block = "net";
          format = " $icon {$ssid $signal_strength|Wired} $speed_up.eng(prefix:K) / $speed_down.eng(prefix:K) ";
          interval = 5;
        }
        {
          block = "time";
          interval = 5;
          format = " $timestamp.datetime(f:'%a %d.%m %R') ";
        }
      ];
    };
  };
}
