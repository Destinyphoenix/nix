# hosts/<hostname>/hm-modules.nix
#
# NUR Ergänzungen zu defaultHomeModules – kein Ersatz! Wird in flake.nix
# per `hostHmModules ++ defaultHomeModules` (siehe mkHost,
# useDefaultValues) zusammengeführt.
#
# Bei useDefaultValues = true  (Standard): diese Liste kommt ZUSÄTZLICH
#   zu defaultHomeModules dazu.
# Bei useDefaultValues = false: nur diese Liste zählt, defaultHomeModules
#   fällt komplett weg – dann hier ggf. auch Basis-Module manuell
#   reinkopieren.
#
# Pfade sind relativ zu diesem Ordner (hosts/<hostname>/), daher ../../
# zurück zur Repo-Wurzel. Leere Liste [ ] ist ein gültiger Inhalt, falls
# ein Host gar keine Ergänzungen braucht.

[
  # Beispiel: zusätzliches HM-Modul nur für diesen Host
  # ../../hm-modules/dark-mode.nix

  # Inline-Overrides / enable-Regeln nur für diesen Host (nutzt z.B. das
  # options.terminal.enable-Pattern aus hm-modules/terminal.nix):
  # {
  #   terminal.enable = false;
  # }
]
