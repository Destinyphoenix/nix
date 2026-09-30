{
  pkgs,
  lib,
  # Platten, die NUR in dieser gaming-Specialisation gemountet werden.
  # Siehe hosts/desktop/gaming.nix für die ausführliche Erklärung.
  extraDisksGaming ? [ ],
  ...
}:
{
  specialisation = {
    gaming.configuration = {
      fileSystems = lib.listToAttrs (
        map (disk: {
          name = disk.mountPoint;
          value = {
            device = "/dev/disk/by-uuid/${disk.uuid}";
            fsType = disk.fsType or "xfs";
            options = [
              "nofail"
              "x-systemd.automount"
              "x-systemd.device-timeout=10"
              "x-systemd.mkdir"
            ]
            ++ (disk.options or [ ]);
          };
        }) extraDisksGaming
      );

      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
        };
        # Kein CPU-Pinning/GPU-Tuning wie beim Desktop (5950X + dedizierte
        # GPU) – auf dem Laptop nur die Defaults, Akkulaufzeit/Thermik
        # vertragen keine aggressive Übernahme.
        gamemode.enable = true;
        gamescope = {
          enable = true;
          capSysNice = true;
        };
      };
      hardware.steam-hardware.enable = true;

      # Clean Quiet Boot – kein zen-Kernel/amd_pstate=active wie beim
      # Desktop, Standardkernel reicht auf dem Laptop.
      boot = {
        kernelParams = [
          "quiet"
          "splash"
          "loglevel=3"
        ];
        plymouth.enable = true;
      };

      # Login bleibt bestehen (tuigreet, wie im Normalbetrieb aus
      # modules/login.nix), nur --cmd wechselt von sway auf den Gaming-Start.
      # Kein Auto-Login mehr: wer sich hier einloggt, macht das idealerweise
      # über das eingeschränkte steam-Konto (siehe modules/steam-user.nix),
      # nicht über das Hauptkonto.
      services = {
        xserver.enable = false;
        greetd = {
          settings = {
            default_session = lib.mkForce {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd '${lib.getExe pkgs.gamescope} -f -e --xwayland-count 2 -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1'";
              user = "greeter";
            };
          };
        };
      };
    };
  };
}
