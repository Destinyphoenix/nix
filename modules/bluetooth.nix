# Bluetooth — Systemseitige Aktivierung (BlueZ).
# Kein Applet (blueman) nötig, Geräteauswahl läuft über tofi
# (siehe hm-modules/bluetooth.nix).
{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
