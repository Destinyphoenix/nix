# flake.nix
{
  description = "Phoenix's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Default-Theme, falls ein Host keins angibt.
      defaultTheme = import ./theme.nix;

      # Default NixOS-Module – identisch zum bisherigen Stand.
      defaultModules = [
        ./configuration.nix
        ./modules/login.nix
        ./modules/network.nix
        #./modules/zsa.nix
        ./modules/sway.nix
        ./modules/terminal.nix
        ./modules/cleanup.nix
        ./modules/brave-policies.nix
        #./specialisations/gaming.nix
        #./modules/docker.nix
        ./modules/bluetooth.nix
      ];

      # Default Home-Manager-Module – identisch zum bisherigen home.nix-Inhalt.
      defaultHomeModules = [
        ./hm-modules/tofi/tofi.nix
        ./hm-modules/git.nix
        ./hm-modules/zed.nix
        ./hm-modules/brave.nix
        ./hm-modules/sway/hm-sway.nix
        ./hm-modules/terminal.nix
        ./hm-modules/tofi/bluetooth.nix
      ];

      # Baut eine komplette NixOS-Config für einen Host.
      mkHost =
        {
          hostname,
          username,
          fullName,
          mail,
          system ? "x86_64-linux",
          theme ? defaultTheme,
          # true  = defaultModules/defaultHomeModules werden mit den
          #         Host-Dateien zusammengeführt (Host-Dateien = Ergänzung)
          # false = Host-Dateien sind die einzige Quelle, Defaults fallen weg
          useDefaultValues ? true,
          extraModules ? [ ],
          extraHomeModules ? [ ],
        }:
        let
          hostDir = ./hosts/${hostname};

          # Host-Dateien enthalten AUSSCHLIESSLICH Ergänzungen, nie einen
          # kompletten Ersatz – sie werden immer an die (ggf. leere) Basis
          # angehängt, nie anstelle von ihr benutzt.
          hostNixModules = import (hostDir + /nix-modules.nix);
          hostHmModules = import (hostDir + /hm-modules.nix);
          hardwareConfig = hostDir + /hardware-configuration.nix;

          modules = (if useDefaultValues then defaultModules else [ ]) ++ hostNixModules;

          homeModules = (if useDefaultValues then defaultHomeModules else [ ]) ++ hostHmModules;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              username
              fullName
              mail
              hostname
              inputs
              ;
          };
          modules =
            modules
            ++ extraModules
            ++ [
              hardwareConfig
              home-manager.nixosModules.home-manager
              {
                networking.hostName = "${hostname}-${username}";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "bak";
                  extraSpecialArgs = {
                    inherit
                      username
                      mail
                      fullName
                      theme
                      inputs
                      hostname
                      ;
                    homeModules = homeModules ++ extraHomeModules;
                  };
                  users.${username} = import ./home.nix;
                };
              }
            ];
        };
    in
    {
      nixosConfigurations = {
        # Nutzt Defaults + eigene Ergänzungen aus hosts/phoenix/
        laptop = mkHost {
          hostname = "laptop";
          username = "phoenix";
          fullName = "phoenix";
          mail = "phoenix.l6iz7@passmail.net";
          useDefaultValues = true;
        };

        # Desktop – eigenes Theme, eigene Hardware, ein Modul mehr
        # desktop = mkHost {
        #   hostname = "desktop";
        #   username = "xyz";
        #   fullName = "Xyz Name";
        #   mail = "xyz@example.net";
        #   hardwareConfig = ./hosts/xyz/hardware-configuration.nix;
        #   theme = import ./themes/xyz-theme.nix;
        #   #extraModules = [ ./modules/ollama.nix ];
        # };
      };
    };
}
