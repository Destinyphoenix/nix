{
  config,
  lib,
  pkgs,
  ...
}:

let
  swaylock = lib.getExe config.programs.swaylock.package;
  swaymsg = "${pkgs.sway}/bin/swaymsg";
in
{
  ##########################################################################
  ### Idle-Management (swayidle) – ersetzt hypridle
  ##########################################################################
  # Läuft als systemd-user-Service an graphical-session.target.
  # Timeouts 1:1 aus deiner hypridle.conf übernommen.
  services.swayidle = {
    enable = true;

    events = {
      before-sleep = "${swaylock} -f";
      lock = "${swaylock} -f";
      after-resume = "${swaymsg} 'output * power on'";
    };

    timeouts = [
      # 2.5 min: Monitor-Backlight dimmen (min. statt 0 wg. OLED)
      {
        timeout = 150;
        command = "brightnessctl -s set 10";
        resumeCommand = "brightnessctl -r";
      }
      # 2.5 min: Tastatur-Backlight aus
      {
        timeout = 150;
        command = "brightnessctl -sd rgb:kbd_backlight set 0";
        resumeCommand = "brightnessctl -rd rgb:kbd_backlight";
      }
      # 5 min: sperren (über loginctl -> löst das 'lock'-Event oben aus)
      {
        timeout = 300;
        command = "loginctl lock-session";
      }
      # 5.5 min: Bildschirm aus (ersetzt hyprctl dispatch dpms off)
      {
        timeout = 330;
        command = "${swaymsg} 'output * power off'";
        resumeCommand = "${swaymsg} 'output * power on' && brightnessctl -r";
      }
      # 30 min: Suspend
      {
        timeout = 1800;
        command = "systemctl suspend";
      }
    ];
  };
}
