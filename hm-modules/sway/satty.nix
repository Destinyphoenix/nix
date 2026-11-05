{ theme, ... }:
{
  ##########################################################################
  ### Screenshot-Annotation (satty)
  ##########################################################################
  # Zeichnen auf dem Screenshot nach der Regionsauswahl.
  # Keybinding und Fensterregel liegen in hm-sway.nix.
  programs.satty = {
    enable = true;

    settings = {
      general = {
        initial-tool = "brush";
        copy-command = "wl-copy";
        early-exit = [ "all" ]; # nach Kopieren/Speichern direkt schließen
        output-filename = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
      };
      font.family = theme.font;
      color-palette.palette = map (color: "${color}ff") [
        theme.primary
        theme.error
        theme.warning
        theme.success
        theme.info
        theme.foreground
      ];
    };
  };

  # satty legt den Zielordner beim Speichern nicht selbst an.
  home.file."Pictures/Screenshots/.keep".text = "";
}
