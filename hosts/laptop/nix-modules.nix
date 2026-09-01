# hosts/<hostname>/nix-modules.nix
#
# NUR Ergänzungen zu defaultModules – kein Ersatz! Wird in flake.nix per
# `hostNixModules ++ defaultModules` (siehe mkHost, useDefaultValues)
# zusammengeführt.
#
# Bei useDefaultValues = true  (Standard): diese Liste kommt ZUSÄTZLICH
#   zu defaultModules dazu.
# Bei useDefaultValues = false: nur diese Liste zählt, defaultModules
#   fällt komplett weg – dann hier ggf. auch Basis-Module manuell
#   reinkopieren.
#
# Pfade sind relativ zu diesem Ordner (hosts/<hostname>/), daher ../../
# zurück zur Repo-Wurzel. Leere Liste [ ] ist ein gültiger Inhalt, falls
# ein Host gar keine Ergänzungen braucht.

[
  # Beispiel: zusätzliches Modul nur für diesen Host
  # ../../modules/ollama.nix

  # Inline-Overrides / enable-Regeln nur für diesen Host
  # {
  #   services.foo.enable = true;
  #   programs.bar.enable = false;
  # }
]
