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

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          # chaotic.nixosModules.default   # enable with the cachy input above
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.phoenix = import ./home.nix;
            # Back up pre-existing files instead of failing the build.
            home-manager.backupFileExtension = "bak";
          }
        ];
      };
    };
}
