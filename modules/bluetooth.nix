# Bluetooth — Systemseitige Aktivierung (BlueZ).
# Kein Applet (blueman) nötig, Geräteauswahl läuft über tofi
# (siehe hm-modules/tofi/bluetooth.nix).
#
# Härtung: Funkmodul bleibt aus, bis tofi-bluetooth es einschaltet;
# nicht sichtbar, nur während eines Pairings koppelbar, LE-Adressen randomisiert.
{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    # Aus bis Bedarf – tofi-bluetooth schaltet beim Start ein
    powerOnBoot = false;
    settings.General = {
      # Explizit, auch wenn BlueZ-Default
      Discoverable = false;
      # Pairable nur, wenn das Skript es gezielt einschaltet
      AlwaysPairable = false;
      # Sicherheitsnetz: Pairable fällt nach 120 s automatisch zurück
      PairableTimeout = 120;
      # Resolvable Private Addresses gegen Tracking über feste MAC
      Privacy = "device";
    };
  };
}
