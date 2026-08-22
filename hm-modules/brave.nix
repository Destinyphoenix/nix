# Brave.
#
# Home Manager erzeugt daraus JSON-Dateien unter
#   ~/.config/BraveSoftware/Brave-Browser/External Extensions/<id>.json
# mit dem Inhalt { "external_update_url": ... }.
#
# WICHTIG — anders als git.nix oder zed.nix ist das NICHT reproduzierbar:
# Nix legt nur einen "bitte installieren"-Zettel ab, die Extension selbst lädt
# Brave zur Laufzeit aus dem Chrome Web Store. Keine gepinnte Version, kein
# Hash, beim `nixos-rebuild build` wird nichts heruntergeladen, und du kannst
# die Extensions im Browser weiterhin deaktivieren oder entfernen.
{ ... }:

{
  programs.brave = {
    enable = true;

    # IDs jeweils aus dem letzten Segment der Chrome-Web-Store-URL.
    extensions = [
      { id = "ghmbeldphafepmbegfdlkpapadhbakde"; } # Proton Pass
      { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
    ];

    # Du nutzt Hyprland — ohne das läuft Brave über XWayland
    # (unscharf auf HiDPI, kein natives Fractional Scaling).
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-wayland-ime"
      "--force-dark-mode"
    ];
  };
}
