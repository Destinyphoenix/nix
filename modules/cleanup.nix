{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
    persistent = true; # holt verpasste Läufe nach (z.B. Rechner war aus)
  };
  boot.loader.systemd-boot.configurationLimit = 5;
}
