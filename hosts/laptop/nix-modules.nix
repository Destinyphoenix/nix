# hosts/<hostname>/nix-modules.nix

[

  ./gaming.nix
  ../../modules/zsa.nix
  ../../modules/docker.nix
  ../../modules/protonvpn.nix

  ../../modules/eduroam/default.nix

  # Inline-Overrides / enable-Regeln nur für diesen Host
  # {
  #   services.foo.enable = true;
  #   programs.bar.enable = false;
  # }
]
