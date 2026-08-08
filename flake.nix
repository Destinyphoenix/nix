{
  description = "Phoenix's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OPTIONAL CachyOS kernel — verify the currently-maintained repo first,
    # then uncomment one and add it to the outputs args + modules list below.
    #   chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #   cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      username = "phoenix";
      fullName = "phoenix";
      mail = "phoenix.l6iz7@passmail.net";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.phoenix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            username
            fullName
            mail
            inputs
            ;
        }; # <-- ADD THIS LINE
        modules = [
          ./configuration.nix
          ./modules/zsa.nix
          ./modules/sway.nix
          # chaotic.nixosModules.default   # enable with the cachy input above
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              extraSpecialArgs = {
                inherit
                  username
                  mail
                  fullName
                  inputs
                  ;
              };
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
