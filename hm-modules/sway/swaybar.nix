{
  config,
  lib,
  pkgs,
  ...
}:
{

  ##########################################################################
  ### Statusleiste (swaybar + i3status-rust)
  ##########################################################################
  programs.i3status-rust = {
    enable = true;
    bars.default = {
      icons = "material-nf";
      theme = "gruvbox-dark";
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
        { block = "sound"; }
        { block = "battery"; }
        {
          block = "time";
          interval = 5;
          format = " $timestamp.datetime(f:'%a %d.%m %R') ";
        }
      ];
    };
  };
}
