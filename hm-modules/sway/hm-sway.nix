{
  config,
  lib,
  pkgs,
  theme,
  ...
}:
# Quick reference for sway's modifier names:

# Mod1 = Alt
# Mod4 = Super/Windows key (your $mainMod)
# Shift = Shift (used as-is, no Mod number)
# Ctrl/Control = Ctrl (also used as-is)

# Sway – portiert aus der bestehenden hyprland.conf.
# Enthält zusätzlich Idle-Management (swayidle) und Screen-Lock (swaylock)
# als Ersatz für hypridle/hyprlock – bewusst gebündelt in diesem Modul.
let
  swaylock = lib.getExe config.programs.swaylock.package;
  swaymsg = "${pkgs.sway}/bin/swaymsg";
in
{
  imports = [
    ./swayidle.nix
    ./swaylock.nix
    ./swaybar.nix
    ./wallpaper.nix
  ];
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4"; # SUPER als Haupt-Modifikator ($mainMod)
      terminal = "kitty";

      # Fenster mit SUPER + Maus verschieben (LMB) / vergrößern (RMB).
      # Entspricht deinen Hyprland-Binds  bindm mouse:272 / mouse:273.
      floating.modifier = "Mod4";

      window = {
        border = 2;
        titlebar = false;
      };
      gaps = {
        inner = 8; # 5
        outer = 4; # 20
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
      #bars = [ ];
      # im wayland.windowManager.sway.config-Block:
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
          fonts = {
            names = [ theme.font ];
            size = theme.fontSize * 1.0;
          };
        }
      ];

      # exec-once aus der hyprland.conf.
      # hypridle entfällt -> läuft jetzt als services.swayidle (unten).
      # Falls waybar bei dir als systemd-user-Service läuft, hier entfernen.
      startup = [
        { command = "swaysome init"; }

        #{ command = "waybar"; }
        #  { command = "nm-applet --indicator"; }
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
        "Mod4+n" = "exec networkmanager_dmenu"; # WLAN-Picker (tofi)
        # Mod4+p (pseudo, dwindle) hat kein Sway-Äquivalent -> entfällt

        # --- Fokus (deine Belegung: j = hoch, k = runter) ---
        "Mod4+Left" = "focus left";
        "Mod4+Right" = "focus right";
        "Mod4+Up" = "focus up";
        "Mod4+Down" = "focus down";

        # --- Workspace wechseln (swaysome: pro Output namespaced) ---
        "Mod4+1" = "exec swaysome focus 1";
        "Mod4+2" = "exec swaysome focus 2";
        "Mod4+3" = "exec swaysome focus 3";
        "Mod4+4" = "exec swaysome focus 4";
        "Mod4+5" = "exec swaysome focus 5";
        "Mod4+6" = "exec swaysome focus 6";
        "Mod4+7" = "exec swaysome focus 7";
        "Mod4+8" = "exec swaysome focus 8";
        "Mod4+9" = "exec swaysome focus 9";
        "Mod4+0" = "exec swaysome focus 0";

        # --- Fenster auf Workspace verschieben (swaysome) ---
        "Mod4+Shift+1" = "exec swaysome move 1";
        "Mod4+Shift+2" = "exec swaysome move 2";
        "Mod4+Shift+3" = "exec swaysome move 3";
        "Mod4+Shift+4" = "exec swaysome move 4";
        "Mod4+Shift+5" = "exec swaysome move 5";
        "Mod4+Shift+6" = "exec swaysome move 6";
        "Mod4+Shift+7" = "exec swaysome move 7";
        "Mod4+Shift+8" = "exec swaysome move 8";
        "Mod4+Shift+9" = "exec swaysome move 9";
        "Mod4+Shift+0" = "exec swaysome move 0";

        # --- Multi-Monitor (swaysome) ---
        "Mod4+Mod1+1" = "exec swaysome focus-group 1";
        "Mod4+Mod1+2" = "exec swaysome focus-group 2";
        "Mod4+Mod1+3" = "exec swaysome focus-group 3";
        "Mod4+Mod1+o" = "exec swaysome workspace-group-next-output";
        # --- Fenster in andere Output-Gruppe verschieben (swaysome) ---
        "Mod4+Mod1+Shift+1" = "exec swaysome move-to-group 0";
        "Mod4+Mod1+Shift+2" = "exec swaysome move-to-group 1";
        "Mod4+Mod1+Shift+3" = "exec swaysome move-to-group 2";
        # --- Scratchpad (magic) ---
        "Mod4+s" = "scratchpad show"; # togglespecialworkspace magic
        "Mod4+Shift+s" = "move scratchpad"; # movetoworkspace special:magic

        # --- Durch Workspaces blättern ---
        "Mod4+Shift+l" = "workspace next"; # workspace e+1
        "Mod4+Shift+h" = "workspace prev"; # workspace e-1

        # --- Farbtemperatur (gammastep statt hyprsunset) ---
        "Mod4+F9" = "exec gammastep -x"; # identity / Filter aus
        "Mod4+F10" = "exec gammastep -O 4000"; # manuell warm

        "Mod4+l" = "exec  ${swaylock} -f";
        #command = "${swaylock} -f";
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
    kitty
    nautilus
    tofi
    swaysome

    # --- waylock (zum Testen als swaylock-Alternative) ---
    # waylock
    # Danach in services.swayidle oben die Lock-Befehle umstellen auf:
    #   "${pkgs.waylock}/bin/waylock -fork-on-lock"
    # und security.pam.services.waylock im NixOS-Modul aktivieren.
  ];

}
