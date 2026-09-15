# modules/protonvpn.nix
#
# Offizieller ProtonVPN-CLI-Client (proton-vpn-cli, Binary: `protonvpn`).
# Nutzt NetworkManager als Backend – fügt sich damit nahtlos neben
# modules/network.nix ein, statt eine eigene OpenVPN/WireGuard-Stack
# mitzubringen. Ersetzt die inoffizielle, nicht mehr gepflegte
# protonvpn-cli-ng (Community, Python/OpenVPN).
#
# Der Client braucht einen Secret-Service (libsecret), um den
# Session-Token nach dem Login abzulegen. Der Provider dafür ist NICHT
# hier definiert, sondern in hm-modules/pass.nix (pass-secret-service,
# GPG/YubiKey-gestützt statt gnome-keyring) – auf Systemebene wird hier
# nur das CLI-Paket selbst installiert.
#
# WICHTIG – einmaliger manueller Schritt:
#   protonvpn signin <proton-username>
# Das Passwort wird NIE in dieser Config oder im Nix-Store gespeichert –
# nur interaktiv abgefragt, der resultierende Session-Token landet
# verschlüsselt im pass-Store (siehe hm-modules/pass.nix), also
# letztlich auf dem YubiKey-Encrypt-Subkey.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.proton-vpn-cli ];
  services.gnome.gnome-keyring.enable = true;

  # Entsperrt den Login-Keyring automatisch mit dem greetd-Passwort.
  # Ohne das müsste man sich nach jedem Boot ein zweites Mal (für den
  # Keyring) authentifizieren, bevor "protonvpn connect" im Sway-
  # Autostart überhaupt funktionieren kann.
  security.pam.services.greetd.enableGnomeKeyring = true;
}
