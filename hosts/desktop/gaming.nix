{
  pkgs,
  lib,
  # Platten, die NUR in dieser gaming-Specialisation gemountet werden
  # (im normalen Boot bleiben sie unangetastet). Kommt aus
  # hosts/<hostname>/disks.nix, Feld `extraDisksGaming` – das Feld
  # `extraDisks` dort ist für IMMER gemountete Platten (siehe
  # modules/extra-disks.nix) und hat mit dieser Datei nichts zu tun.
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
      # ... programs.steam/gamemode/gamescope, boot, environment.systemPackages,
      # services.greetd wie zuvor, unverändert
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
        gamemode = {
          enable = true;
          settings = {
            general = {
              renice = 10;
              ioprio = 0; # Realtime-IO-Priorität für den Spieleprozess
            };
            gpu = {
              apply_gpu_optimisations = "accept-responsibility";
              gpu_device = 0;
              amd_performance_level = "high";
            };
            cpu = {
              park_cores = "no"; # genug Kerne (5950X etc.) – keine parken, viele Spiele profitieren von SMT
              pin_cores = "no";
            };
          };
        };
        gamescope = {
          enable = true;
          capSysNice = true;
        };

      };
      hardware.steam-hardware.enable = true;
      # Clean Quiet Boot
      boot = {
        # zen-Kernel: niedrigere Latenz/aggressiveres Scheduling, nur in dieser
        # Specialisation aktiv – der normale Boot-Eintrag bleibt unangetastet.
        kernelPackages = pkgs.linuxPackages_zen;
        kernelParams = [
          "quiet"
          "splash"
          "loglevel=3"
          #"console=/dev/null"
          "amdgpu.gttsize=8192" # MB — increases GPU-addressable system RAM
          "amd_pstate=active" # AMD-eigener P-State-Treiber steuert Frequenz+Spannung, reagiert schneller als generischer Governor
        ];
        plymouth.enable = true;
        kernel.sysctl = {
          # manche Spiele/Engines (Source2, Star Citizen, ...) brauchen mehr
          # gemappte Speicherbereiche als der Kernel-Default erlaubt
          "vm.max_map_count" = 2147483642;
        };
      };
      environment.systemPackages = with pkgs; [
        mangohud # FPS/Perf-Overlay, opt-in via `mangohud %command%` in Steam-Startoptionen
        protonup-qt # GUI zum Verwalten von Proton-GE-Versionen
      ];

      # Gamescope Auto Boot from TTY – Login bleibt bestehen (tuigreet, wie im
      # Normalbetrieb aus modules/login.nix), nur --cmd wechselt von sway auf
      # den Gaming-Start. Kein Auto-Login mehr: wer sich hier einloggt, macht
      # das idealerweise über das eingeschränkte steam-Konto
      # (siehe modules/steam-user.nix), nicht über das Hauptkonto.
      services = {
        xserver.enable = false; # Assuming no other Xserver needed
        greetd = {
          settings = {
            default_session = lib.mkForce {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd '${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1'";
              user = "greeter";
            };
          };
        };
      };
      # Ohne diese Wartemarke kann greetd/tuigreet vor NetworkManager
      # hochkommen; die Verbindung ist dann noch nicht aufgebaut, wenn Steam
      # startet, und es startet offline.
      systemd.services.greetd = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

    };
  };
}
