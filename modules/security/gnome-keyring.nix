# modules/security/gnome-keyring.nix
#
# gnome-keyring als Secret-Service-Provider (org.freedesktop.secrets).
# Nicht zusammen mit hm-modules/security/keepassxc.nix oder pass.nix
# importieren: Nur eine Anwendung kann den D-Bus-Namen belegen.
{ ... }:
{
  services.gnome.gnome-keyring.enable = true;

  # Entsperrt den Login-Keyring automatisch mit dem greetd-Passwort.
  # Ohne das müsste man sich nach jedem Boot ein zweites Mal (für den
  # Keyring) authentifizieren, bevor "protonvpn connect" im Sway-
  # Autostart überhaupt funktionieren kann.
  security.pam.services.greetd.enableGnomeKeyring = true;
}
