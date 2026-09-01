# hosts/<hostname>/nix-modules.nix

[
  # Beispiel: zusätzliches Modul nur für diesen Host
  # ../../modules/ollama.nix

  ../../specialisations/gaming.nix
  ../../modules/zsa.nix
  ../../modules/docker.nix

  # Inline-Overrides / enable-Regeln nur für diesen Host
  # {
  #   services.foo.enable = true;
  #   programs.bar.enable = false;
  # }
]
