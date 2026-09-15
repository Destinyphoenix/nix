# modules/gaming.nix
# Gaming-Optimierungen für AMD-Hardware (CPU + dGPU) – Opt-in-Modul,
# wird pro Host importiert (z.B. hosts/desktop/default.nix)
{ config, lib, pkgs, ... }:

{
  # --- Kernel ---
  # zen-Kernel: niedrigere Latenz, aggressiveres Scheduling – besser fürs Gaming
  # als der Standard-Kernel, dafür etwas kürzere Support-Fenster bei Sicherheitsupdates.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    # amd_pstate im "active"-Modus lässt den AMD-eigenen P-State-Treiber
    # Frequenz UND Spannung steuern (statt nur Frequenz wie im "passive"-Modus) –
    # reagiert schneller auf Lastspitzen als der generische cpufreq-Governor.
    "amd_pstate=active"
  ];

  # --- GPU (amdgpu / RDNA2, kein OC/UV) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Pflicht für Steam/Proton – die meisten Spiele sind 32-Bit
  };
  # RADV (Mesa) ist der Standard-Vulkan-Treiber und für RDNA2 die richtige Wahl –
  # kein extra AMDVLK-Paket nötig, da wir nicht zwischen Treibern wechseln wollen.

  # --- GameMode ---
  # Schaltet Governor/Prozess-Priorität automatisch um, sobald ein Spiel läuft,
  # statt den ganzen Desktop dauerhaft auf "performance" zu halten (spart Strom/Lautstärke im Alltag).
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0; # Realtime-IO-Priorität für den Spieleprozess
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high"; # nur Performance-Level, kein manuelles OC/UV
      };
      cpu = {
        park_cores = "no"; # 5950X hat genug Kerne – keine parken, viele Spiele profitieren von SMT
        pin_cores = "no";
      };
    };
  };

  # --- Steam ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  # --- Controller-Support ---
  hardware.steam-hardware.enable = true; # Udev-Regeln für Steam Controller / Steam Deck Controller
  # hardware.xone.enable = true; # nur aktivieren, falls ein Xbox-Wireless-Dongle genutzt wird

  # --- sysctl-Tuning ---
  boot.kernel.sysctl = {
    # manche Spiele/Engines (z.B. Source2, Star Citizen) brauchen mehr gemappte
    # Speicherbereiche als der Kernel-Default erlaubt
    "vm.max_map_count" = 2147483642;
  };

  environment.systemPackages = with pkgs; [
    mangohud     # FPS/Perf-Overlay, opt-in nutzbar via `mangohud %command%` in Steam-Startoptionen
    protonup-qt  # GUI zum Verwalten von Proton-GE-Versionen
  ];
}
