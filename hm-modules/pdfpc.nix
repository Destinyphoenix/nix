# pdfpc (PDF-Präsentationen mit Presenter-Ansicht) unter Sway.
#
# Beide Fenster (Presenter und Präsentation) starten als normale Fenster
# (windowed-mode = both) und lassen sich wie jedes andere Fenster kacheln,
# verschieben oder per Mod4+f in den Vollbildmodus schalten.
#
# Einzige Sway-Regel: solange ein pdfpc-Fenster sichtbar ist, sperrt
# swayidle den Bildschirm nicht. Erkannt wird über den Titel
# ("pdfpc - presentation (<datei>)" bzw. "pdfpc - presenter (<datei>)").
{
  pkgs,
  lib,
  theme,
  ...
}:

let
  # Optionen für ~/.config/pdfpc/pdfpcrc, siehe `man 5 pdfpcrc`.
  settings = {
    windowed-mode = "both"; # kein automatisches Vollbild
    pointer-color = theme.primary;
    black-on-end = true; # schwarze Folie nach der letzten Seite
  };

  toValue = v: if lib.isBool v then lib.boolToString v else toString v;
in
{
  home.packages = [ pkgs.pdfpc ];

  xdg.configFile."pdfpc/pdfpcrc".text = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "option ${name} ${toValue value}") settings
  );

  wayland.windowManager.sway.config.window.commands = [
    {
      criteria.title = "^pdfpc - ";
      command = "inhibit_idle visible";
    }
  ];
}
