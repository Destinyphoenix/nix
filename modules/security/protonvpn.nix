# modules/security/protonvpn.nix
#
# Offizieller ProtonVPN-CLI-Client (proton-vpn-cli, Binary: `protonvpn`).
# Nutzt NetworkManager als Backend – fügt sich damit nahtlos neben
# modules/network.nix ein, statt eine eigene OpenVPN/WireGuard-Stack
# mitzubringen. Ersetzt die inoffizielle, nicht mehr gepflegte
# protonvpn-cli-ng (Community, Python/OpenVPN).
#
# Der Client braucht einen Secret-Service (libsecret), um den
# Session-Token nach dem Login abzulegen. Der Provider dafür ist NICHT
# hier definiert, sondern wird pro Host gewählt (siehe
# modules/security/gnome-keyring.nix und hm-modules/security/).
#
# WICHTIG – einmaliger manueller Schritt:
#   protonvpn signin <proton-username>
# Das Passwort wird NIE in dieser Config oder im Nix-Store gespeichert –
# nur interaktiv abgefragt, der resultierende Session-Token landet
# verschlüsselt beim Secret-Service-Provider des Hosts.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.proton-vpn-cli ];
}
