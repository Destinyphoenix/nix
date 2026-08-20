{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
    persistent = true; # holt verpasste Läufe nach (z.B. Rechner war aus)
  };
}
