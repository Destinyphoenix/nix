# hm-modules/pass.nix
#
# GPG-gestützter Passwortspeicher (pass) + Secret-Service-Brücke
# (pass-secret-service). Ersetzt gnome-keyring als Provider für
# org.freedesktop.secrets: Anwendungen, die per Secret-Service nach
# einem Token fragen (z. B. die ProtonVPN-CLI, siehe protonvpn.nix),
# bekommen den Wert aus der ~/.password-store-Struktur – verschlüsselt
# auf dieselbe GPG-Identität (mail), die auch für Git-Signing und
# SSH-über-gpg-agent genutzt wird (siehe git.nix), und damit letztlich
# auf den Encrypt-Subkey auf dem YubiKey.
#
# Vorteil gegenüber gnome-keyring: keine zweite, unabhängige
# Verschlüsselungsdomäne (Login-Passwort) neben der bereits bestehenden
# YubiKey/GPG-Vertrauenskette – ein Secret, ein Trust-Anchor.
# Nachteil: Entsperren hängt am gpg-agent-Cache (defaultCacheTtl in
# git.nix) statt an PAM. Läuft der Cache ab, fragt pinentry erneut nach
# der YubiKey-PIN, bevor z. B. "protonvpn connect" im Sway-Autostart
# funktioniert – anders als bei gnome-keyring gibt es kein automatisches
# Entsperren beim greetd-Login.
#
# Einmaliger manueller Schritt (wie bei "protonvpn signin" – kein
# Secret landet in dieser Config oder im Nix-Store):
#   pass init <mail-Adresse>
{ mail, ... }:
{
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_KEY = mail;
    };
  };

  # Exponiert den pass-Store über org.freedesktop.secrets (D-Bus).
  # Einziger Secret-Service-Provider im System halten – NICHT
  # zusätzlich gnome-keyring aktivieren, das HM-Modul lehnt das per
  # assertion ab ("Only one secrets service per user").
  services.pass-secret-service.enable = true;
}
