# modules/eduroam/default.nix
#
# eduroam (HKA) deklarativ statt über das CAT-Python-Skript.
# Alle Werte stammen 1:1 aus dem offiziellen CAT-Installer der HKA
# (cat.eduroam.org → "University of Applied Sciences Karlsruhe"):
#   PEAP / MSCHAPv2, anonyme Außenidentität, Server-Validierung per
#   CA-Bundle + Domain-Match auf die RADIUS-Server.
#
# Warum nicht das CAT-Skript?
#   - legt ~/.config/cat_installer an (dein ~/.config ist ein Git-Repo)
#   - schreibt eine imperative NM-Verbindung, die kein Rebuild reproduziert
#   - braucht dbus-python im Python-Env
#
# Passwort-Handling (wichtigster Punkt):
#   password-flags = 1 ("agent-owned") → NetworkManager speichert das
#   Passwort NICHT selbst, sondern fragt einen Secret-Agent (nm-applet).
#   nm-applet legt es über org.freedesktop.secrets ab – also im
#   gnome-keyring (modules/keyring.nix), verschlüsselt mit dem
#   Login-Passwort und beim greetd-Login entsperrt. Kein Secret in
#   Config, Nix-Store oder /etc/NetworkManager/system-connections.
#
# Einmaliger manueller Schritt:
#   Alte CAT-Verbindung (falls vorhanden) entfernen:
#     nmcli connection delete eduroam
#   Beim ersten Verbinden fragt nm-applet das HKA-Passwort ab und
#   speichert es. Alternativ im Terminal: nmcli --ask connection up eduroam
{ pkgs, username, ... }:
let
  # CA-Bundle als gehashtes Zertifikats-Verzeichnis (ca-path) statt als
  # einzelne Datei (ca-cert). Grund: Bei manchen NM-Versionen (laut CAT
  # 1.54.3–1.58.0) wird aus einer Bundle-Datei nur das ERSTE Zertifikat
  # geladen – hier HARICA ECC. Der HKA-RADIUS hängt aber an
  # GEANT TLS RSA 1 → HARICA TLS RSA Root CA 2021 (7. im Bundle)
  # → "unable to get local issuer certificate".
  # Ein Verzeichnis mit einer Datei pro Zertifikat + openssl-rehash-Links
  # (<hash>.0) funktioniert mit allen NM-Versionen – genau das macht
  # auch der CAT-Installer als Workaround.
  caDir = pkgs.runCommand "hka-eduroam-ca" { nativeBuildInputs = [ pkgs.openssl ]; } ''
    mkdir -p $out
    csplit -s -z -f $out/ca- -b '%02d.pem' ${./hka-ca.pem} \
      '/-----BEGIN CERTIFICATE-----/' '{*}'
    openssl rehash $out
  '';

  # HKA-Kennung (Format: kennung@h-ka.de) – anpassen!
  identity = "abcd1234@h-ka.de";

  # Werte aus dem CAT-Installer (Config.*)
  anonymousIdentity = "anonymous@h-ka.de";
  radiusServers = [
    "radius1.h-ka.de"
    "radius1.hs-karlsruhe.de"
  ];
in
{
  # Secret-Service für das agent-owned Passwort (gnome-keyring).

  ####################################################################
  ### System-Ebene (NixOS) – NetworkManager-Profil
  ####################################################################
  # ensureProfiles schreibt das Profil bei jeder Aktivierung neu
  # (nach /run/NetworkManager/system-connections) → immer deklarativ.
  networking.networkmanager.ensureProfiles.profiles.eduroam = {
    connection = {
      id = "eduroam";
      type = "wifi";
      autoconnect = true;
      # Private Verbindung wie beim CAT-Installer: nur dieser Nutzer
      # darf sie aktivieren; passt zum agent-owned Passwort, das
      # ohnehin erst in der Nutzersitzung verfügbar ist.
      permissions = "user:${username};";
    };

    wifi = {
      ssid = "eduroam";
      mode = "infrastructure";
    };

    # Wie CAT: nur WPA2/3-Enterprise mit CCMP (kein TKIP-Fallback).
    wifi-security = {
      key-mgmt = "wpa-eap";
      proto = "rsn;";
      pairwise = "ccmp;";
      group = "ccmp;";
    };

    "802-1x" = {
      eap = "peap;";
      phase2-auth = "mschapv2";
      inherit identity;
      anonymous-identity = anonymousIdentity;

      # Server-Validierung – NICHT weglassen: ohne CA + Domain-Match
      # kann jeder Fake-AP namens "eduroam" den MSCHAPv2-Hash des
      # Hochschulpassworts abgreifen (offline knackbar).
      # CA-Zertifikate sind öffentlich → dürfen im Nix-Store liegen.
      ca-path = "${caDir}";
      domain-match = builtins.concatStringsSep ";" radiusServers;

      # 1 = agent-owned: Passwort liegt beim Secret-Agent, nicht bei NM.
      password-flags = 1;
    };

    ipv4.method = "auto";
    ipv6.method = "auto";
  };

  ####################################################################
  ### Home-Manager-Ebene – Secret-Agent
  ####################################################################
  # nm-applet als systemd-User-Service (hängt an graphical-session.target,
  # das die Sway-HM-Integration startet). Registriert sich als
  # NM-Secret-Agent → Autoconnect funktioniert ohne Terminal.
  # Paket kommt bereits aus modules/network.nix; falls der Agent später
  # auch für andere Netze gebraucht wird, dorthin verschieben.
  home-manager.users.${username}.services.network-manager-applet.enable = true;
}
