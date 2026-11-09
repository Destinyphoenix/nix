# hosts/<hostname>/nix-modules.nix

[

  ./gaming.nix
  ../../modules/zsa.nix
  ../../modules/docker.nix
  ../../modules/security/protonvpn.nix
  ../../modules/security/yubikey.nix

  ../../modules/eduroam/default.nix

  # Inline-Overrides / enable-Regeln nur für diesen Host
  # {
  #   services.foo.enable = true;
  #   programs.bar.enable = false;
  # }
]
