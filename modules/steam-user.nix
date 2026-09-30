# modules/steam-user.nix
#
# Eingeschränktes Konto für die Gaming-Specialisation (siehe
# hosts/*/gaming.nix): kein wheel/docker/i2c/plugdev, kein Zugriff auf
# SSH-Keys oder den pass-/GPG-Store des Hauptkontos. Login läuft weiterhin
# über tuigreet mit Passwort (siehe modules/login.nix) – nur der
# Berechtigungsumfang ist eingeschränkt.
{
  users.users.steam = {
    isNormalUser = true;
    description = "Gaming (eingeschränkt)";
    extraGroups = [ "gaming" ]; # Schreibzugriff auf extraDisksGaming-Mounts
    # Passwort NICHT hier/im Store setzen – einmalig manuell: `sudo passwd steam`
  };

  users.groups.gaming = { };
}
