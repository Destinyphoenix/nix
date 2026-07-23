{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # ---- Variables ----
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$menu" = "tofi-drun --drun-launch=true";   # your launcher is tofi, not rofi

      # ---- Monitors ----
      # Sensible default so displays always come up. If you prefer managing
      # monitors with nwg-displays, delete this line and instead add, under
      # `extraConfig` below:  source = ~/.config/hypr/monitors.conf
      monitor = [ ",preferred,auto,auto" ];

      # ---- Autostart ----
      exec-once = [
       # "hypridle"
       # "waybar"
        #"nm-applet --indicator"
        #"hyprsunset"
        #"bash -c \"protonvpn connect --country DE --securecore\""
      ];

      # Runs on every reload (dark theme for GTK4 apps)
      exec = [
        "gsettings set org.gnome.desktop.interface color-scheme prefer-dark"
      ];

      # ---- Environment ----
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # ---- Look & feel ----
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;   # was: "yes, please :)"  (Hyprland easter egg -> true)
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global,1,10,default"
          "border,1,5.39,easeOutQuint"
          "windows,1,4.79,easeOutQuint"
          "windowsIn,1,4.1,easeOutQuint,popin 87%"
          "windowsOut,1,1.49,linear,popin 87%"
          "fadeIn,1,1.73,almostLinear"
          "fadeOut,1,1.46,almostLinear"
          "fade,1,3.03,quick"
          "layers,1,3.81,easeOutQuint"
          "layersIn,1,4,easeOutQuint,fade"
          "layersOut,1,1.5,linear,fade"
          "fadeLayersIn,1,1.79,almostLinear"
          "fadeLayersOut,1,1.39,almostLinear"
          "workspaces,1,1.94,almostLinear,fade"
          "workspacesIn,1,1.21,almostLinear,fade"
          "workspacesOut,1,1.94,almostLinear,fade"
          "zoomFactor,1,7,quick"
        ];
      };

      dwindle.preserve_split = true;
      master.new_status = "master";

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      # ---- Input ----
      input = {
        kb_layout = "de";
        kb_options = "caps:swapescape";   # your two kb_options lines merged to this
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
      };

      gesture = [
        { fingers = 3; direction = "horizontal"; action = "workspace"; }
        { fingers = 3; direction = "up"; mods = "SUPER"; action = "fullscreen"; }
      ];

      # ---- Keybindings ----
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, B, exec, brave --password-store=basic"
        "$mainMod, F, fullscreen, 0"

        # focus (vim keys)
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, j, movefocus, u"
        "$mainMod, k, movefocus, d"

        # workspaces  (fixed: SUPER+8 -> ws8; your file bound SUPER+7 twice)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        "$mainMod SHIFT, l, workspace, e+1"
        "$mainMod SHIFT, h, workspace, e-1"

        ", PRINT, exec, hyprshot -m region"

        "$mainMod, F9,  exec, hyprctl hyprsunset identity"
        "$mainMod, F10, exec, hyprctl hyprsunset temperature 4000"
      ];

      bindel = [
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        "$mainMod ALT, up, exec, ddcutil setvcp 10 +10"
        "$mainMod ALT, down, exec, ddcutil setvcp 10 -10"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # ---- Window rules (your newer match: syntax, kept verbatim) ----
      windowrule = [
        # Ignore maximize requests from apps.
        "suppressevent maximize, class:.*"
        # Fix some dragging issues with XWayland.
        "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
      ];
    };

    # Uncomment to hand monitors back to nwg-displays instead of the default above:
    # extraConfig = "source = ~/.config/hypr/monitors.conf";
  };

  # ---- Companion configs: carried verbatim, editable in place ----
  /*
  xdg.configFile."hypr/hypridle.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr/hypridle.conf";
  xdg.configFile."hypr/hyprsunset.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr/hyprsunset.conf";
  xdg.configFile."hypr/hyprlock.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/hypr/hyprlock.conf";
  xdg.configFile."hypr/background/feather.png".source =
    ../dotfiles/hypr/background/feather.png;
    */
}
