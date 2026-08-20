rec {
  # "Phoenix Ember" – Werte abgeleitet aus wallpaper/*.png (schwarzer BG,
  # Neon-Phoenix in Orange→Rot mit gelbem Augen-Glanzlicht). Namen bewusst
  # generisch (Design-Token-Konvention), damit ein späterer Theme-Wechsel
  # kein Umbenennen in jedem Modul erfordert.

  background = "#0a0a0a"; # Haupt-Hintergrund
  surface = "#1a1210"; # Panels/Bars, leicht abgesetzt vom Hintergrund
  foreground = "#f4ece0"; # Haupttext
  muted = "#a89a8c"; # gedämpfter Text (Platzhalter, sekundäre Labels)
  border = "#4a3f38"; # Rahmen/Trenner, Terminal-Comments (ANSI bright black)

  primary = "#ff8c1a"; # Hauptakzent (Cursor, Hervorhebungen, Branding)
  error = "#e8390d"; # Fehler / ANSI red
  warning = "#ffbf3f"; # Warnung / ANSI yellow
  success = "#8a9a5b"; # Erfolg / ANSI green
  info = "#4a6b8a"; # Info / ANSI blue

  accent = primary; # Platzhalter für einen zweiten Akzent, falls später
  # gebraucht (aktuell = primary, um keine Farbe zu erfinden, die im
  # Wallpaper nicht vorkommt)

  font = "JetBrainsMono Nerd Font";
  fontSize = 11;
}
