{ theme, ... }:
{
  ##########################################################################
  ### Benachrichtigungen (mako)
  ##########################################################################
  # Empfängt die notify-send-Meldungen (z.B. aus den tofi-Pickern).
  # Steuerung über makoctl – Keybindings liegen in hm-sway.nix.
  services.mako = {
    enable = true;

    settings = {
      font = "${theme.font} ${toString theme.fontSize}";
      background-color = theme.surface;
      text-color = theme.foreground;
      border-color = theme.border;
      progress-color = "over ${theme.primary}";

      border-size = 2;
      border-radius = 0;
      padding = "10";
      margin = "8";
      width = 350;
      max-visible = 5;
      anchor = "top-right";
      default-timeout = 5000; # ms; 0 = bleibt bis zum Wegklicken

      # Kritische Meldungen (notify-send -u critical) rot umrahmen, ohne Timeout
      "urgency=high" = {
        border-color = theme.error;
        default-timeout = 0;
      };

      "urgency=low" = {
        text-color = theme.muted;
      };

      # Nicht-stören-Modus: Meldungen werden gesammelt, aber nicht angezeigt
      # (erscheinen wieder, sobald der Modus ausgeschaltet wird)
      "mode=do-not-disturb" = {
        invisible = 1;
      };
    };
  };
}
