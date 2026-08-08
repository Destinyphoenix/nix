{
  config,
  lib,
  pkgs,
  ...
}:

# Sway – portiert aus der bestehenden hyprland.conf.
# Enthält zusätzlich Idle-Management (swayidle) und Screen-Lock (swaylock)
# als Ersatz für hypridle/hyprlock – bewusst gebündelt in diesem Modul.
let
  swaylock = lib.getExe config.programs.swaylock.package;
  swaymsg = "${pkgs.sway}/bin/swaymsg";
in
{
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4"; # SUPER als Haupt-Modifikator ($mainMod)
      terminal = "kitty";

      # Fenster mit SUPER + Maus verschieben (LMB) / vergrößern (RMB).
      # Entspricht deinen Hyprland-Binds  bindm mouse:272 / mouse:273.
      floating.modifier = "Mod4";

      gaps = {
        inner = 5; # gaps_in
        outer = 20; # gaps_out
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "de";
          #xkb_options = "caps:swapescape";
        };
        "type:touchpad" = {
          natural_scroll = "disabled"; # natural_scroll = false
        };
      };

      # Keine Standard-Swaybar – wir starten waybar über startup.
      bars = [ ];

      # exec-once aus der hyprland.conf.
      # hypridle entfällt -> läuft jetzt als services.swayidle (unten).
      # Falls waybar bei dir als systemd-user-Service läuft, hier entfernen.
      startup = [
        { command = "waybar"; }
        { command = "nm-applet --indicator"; }
      ];

      # Ersetzt die Sway-Standardbindings vollständig durch die
      # Hyprland-Belegung. (D.h. sway-Defaults wie reload/resize-mode/
      # split entfallen – deine hyprland.conf hatte diese ebenfalls nicht.
      # Mit lib.mkOptionDefault statt einer direkten Zuweisung ließen sie
      # sich zusätzlich behalten.)
      keybindings = {
        # --- Programme ---
        "Mod4+q" = "exec kitty"; # $terminal
        "Mod4+c" = "kill"; # killactive
        "Mod4+m" = "exit"; # exit
        "Mod4+e" = "exec nautilus"; # $fileManager
        "Mod4+v" = "floating toggle"; # togglefloating
        "Mod4+r" = "exec tofi-drun --drun-launch=true"; # $menu
        "Mod4+b" = "exec brave --password-store=basic";
        "Mod4+f" = "fullscreen"; # fullscreen, 0
        # Mod4+p (pseudo, dwindle) hat kein Sway-Äquivalent -> entfällt

        # --- Fokus (deine Belegung: j = hoch, k = runter) ---
        "Mod4+h" = "focus left";
        "Mod4+l" = "focus right";
        "Mod4+j" = "focus up";
        "Mod4+k" = "focus down";

        # --- Workspace wechseln ---
        "Mod4+1" = "workspace number 1";
        "Mod4+2" = "workspace number 2";
        "Mod4+3" = "workspace number 3";
        "Mod4+4" = "workspace number 4";
        "Mod4+5" = "workspace number 5";
        "Mod4+6" = "workspace number 6";
        "Mod4+7" = "workspace number 7"; # war in hyprland.conf doppelt belegt -> korrigiert
        "Mod4+8" = "workspace number 8"; # war per Tastatur nicht erreichbar -> ergänzt
        "Mod4+9" = "workspace number 9";
        "Mod4+0" = "workspace number 10";

        # --- Fenster auf Workspace verschieben ---
        "Mod4+Shift+1" = "move container to workspace number 1";
        "Mod4+Shift+2" = "move container to workspace number 2";
        "Mod4+Shift+3" = "move container to workspace number 3";
        "Mod4+Shift+4" = "move container to workspace number 4";
        "Mod4+Shift+5" = "move container to workspace number 5";
        "Mod4+Shift+6" = "move container to workspace number 6";
        "Mod4+Shift+7" = "move container to workspace number 7";
        "Mod4+Shift+8" = "move container to workspace number 8";
        "Mod4+Shift+9" = "move container to workspace number 9";
        "Mod4+Shift+0" = "move container to workspace number 10";

        # --- Scratchpad (magic) ---
        "Mod4+s" = "scratchpad show"; # togglespecialworkspace magic
        "Mod4+Shift+s" = "move scratchpad"; # movetoworkspace special:magic

        # --- Durch Workspaces blättern ---
        "Mod4+Shift+l" = "workspace next"; # workspace e+1
        "Mod4+Shift+h" = "workspace prev"; # workspace e-1

        # --- Farbtemperatur (gammastep statt hyprsunset) ---
        "Mod4+F9" = "exec gammastep -x"; # identity / Filter aus
        "Mod4+F10" = "exec gammastep -O 4000"; # manuell warm
      };
    };

    # Binds, die Sway-Flags (--locked) oder Shell-Pipes brauchen und sich
    # daher schlecht über das keybindings-Attribut abbilden lassen.
    # --locked bildet dein Hyprland-Flag "l" ab (wirkt auch im Sperrbild-
    # schirm); die Wiederholung beim Halten (Flag "e") ist in Sway Standard.
    extraConfig = ''
      # externe Monitor-Helligkeit (ddcutil), SUPER+ALT+Hoch/Runter
      bindsym --locked Mod4+Mod1+Up   exec ddcutil setvcp 10 +10
      bindsym --locked Mod4+Mod1+Down exec ddcutil setvcp 10 -10

      # Bildschirmhelligkeit (Laptop)
      bindsym --locked XF86MonBrightnessUp   exec brightnessctl s +5%
      bindsym --locked XF86MonBrightnessDown exec brightnessctl s 5%-

      # Lautstärke / Mikrofon
      bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindsym --locked XF86AudioMute        exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym --locked XF86AudioMicMute     exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # Medientasten (playerctl), auch im Sperrbildschirm
      bindsym --locked XF86AudioNext  exec playerctl next
      bindsym --locked XF86AudioPause exec playerctl play-pause
      bindsym --locked XF86AudioPlay  exec playerctl play-pause
      bindsym --locked XF86AudioPrev  exec playerctl previous

      # Screenshot: Region -> Zwischenablage (ersetzt hyprshot -m region)
      bindsym Print exec grim -g "$(slurp)" - | wl-copy
    '';
  };

  ##########################################################################
  ### Idle-Management (swayidle) – ersetzt hypridle
  ##########################################################################
  # Läuft als systemd-user-Service an graphical-session.target.
  # Timeouts 1:1 aus deiner hypridle.conf übernommen.
  services.swayidle = {
    enable = true;

    events = [
      # vor dem Suspend sperren (before_sleep_cmd)
      {
        event = "before-sleep";
        command = "${swaylock} -f";
      }
      # loginctl lock-session -> tatsächliches Sperren
      {
        event = "lock";
        command = "${swaylock} -f";
      }
      # nach dem Aufwachen Display wieder an (after_sleep_cmd)
      {
        event = "after-resume";
        command = "${swaymsg} 'output * power on'";
      }
    ];

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

  ##########################################################################
  ### Screen-Lock (swaylock) – ersetzt hyprlock
  ##########################################################################
  # PAM wird durch programs.sway.enable (NixOS-Modul) automatisch gesetzt.
  # Farben grob aus deiner hyprlock.conf gemappt.
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    # Alternative mit Blur/Screenshot-Effekten (Look näher an hyprlock):
    # package = pkgs.swaylock-effects;

    settings = {
      # Hintergrundbild wie hyprlock – Pfad an deine Repo-Struktur anpassen:
      # image = "${./background/feather.png}";
      color = "191414"; # hyprlock-BG rgba(25, 20, 20, 1.0)
      font-size = 24;
      indicator-radius = 100;
      indicator-thickness = 7;
      show-failed-attempts = true;

      # grob gemappt aus deiner hyprlock.conf:
      ring-color = "151515"; # outer_color rgb(151515)
      inside-color = "c8c8c8"; # inner_color rgb(200,200,200)
      text-color = "0a0a0a"; # font_color rgb(10,10,10)
      key-hl-color = "cc8822"; # check_color rgb(204,136,34)
      ring-ver-color = "cc8822";
      ring-wrong-color = "cc2222"; # fail_color rgb(204,34,34)
    };
  };

  # Werkzeuge, die die Bindings/Autostarts/Lock aufrufen.
  # kitty, nautilus, waybar, tofi und brave werden als bereits anderswo
  # verwaltet angenommen – falls nicht, hier ergänzen.
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    gammastep
    brightnessctl
    ddcutil
    playerctl
    networkmanagerapplet # liefert nm-applet

    # --- waylock (zum Testen als swaylock-Alternative) ---
    # waylock
    # Danach in services.swayidle oben die Lock-Befehle umstellen auf:
    #   "${pkgs.waylock}/bin/waylock -fork-on-lock"
    # und security.pam.services.waylock im NixOS-Modul aktivieren.
  ];
}
