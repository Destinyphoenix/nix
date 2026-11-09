# hm-modules/security/keepassxc.nix
#
# KeePassXC als einziger Secret-Service-Provider (org.freedesktop.secrets),
# entsperrt per Passwort + YubiKey (HMAC-SHA1 Challenge-Response, kein GPG).
# Der Zugriff auf den YubiKey kommt aus modules/security/yubikey.nix.
#
# Alternative zu modules/security/gnome-keyring.nix, nicht zusammen
# importieren. Dessen Daten bleiben unter ~/.local/share/keyrings liegen,
# werden aber nicht übernommen: Secrets von ProtonVPN, eduroam usw. neu
# eingeben.
#
# Einmalige manuelle Schritte (kein Secret in Config oder Nix-Store):
#   1. ykman otp chalresp --touch --generate 2
#      Secret sicher notieren, damit ein Ersatz-Key möglich bleibt.
#   2. In KeePassXC Datenbank anlegen, Passwort + YubiKey als Zugangsdaten.
#   3. Datenbankeinstellungen -> Secret-Service-Integration: eigene Gruppe
#      freigeben, nicht die ganze Datenbank.
{ lib, pkgs, ... }:
{
  programs.keepassxc = {
    enable = true;
    # Home Manager verlinkt die ini read-only in den Nix-Store: KeePassXC
    # meldet deshalb einen Zugriffsfehler, und GUI-Einstellungen bleiben
    # nicht erhalten. Dauerhafte Änderungen gehören hierher.
    settings.FdoSecrets.Enabled = true;
  };

  # shortcut: Fenster schließen beendet auch den Secret Service, weil die Swaybar keinen Tray hat (trayOutput = "none"); Tray aktivieren und MinimizeOnClose setzen, falls das stört.
  wayland.windowManager.sway.config.startup = [
    { command = lib.getExe pkgs.keepassxc; }
  ];
}
