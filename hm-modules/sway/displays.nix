# Display-Management — Monitor-Layout GUI (nwg-displays) + automatisches
# Profil-Switching (kanshi).
#
# nwg-displays: GTK-Oberfläche zum interaktiven Anordnen/Skalieren/Drehen
# von Outputs unter wlroots-Compositors (sway). Rein imperativ bedient,
# aber notwendig: Monitor-Positionen per Maus zu ziehen ist schneller als
# Koordinaten zu erraten. Schreibt beim Speichern automatisch ein
# kanshi-kompatibles Profil nach ~/.config/kanshi/config – das läuft dann
# wieder deklarativ über services.kanshi weiter.
#
# kanshi: wechselt automatisch zwischen den unten definierten Profilen,
# sobald sich die angeschlossenen Outputs ändern (z. B. Laptop-Deckel auf/
# zu, externer Monitor an-/abgesteckt). Output-Namen (eDP-1, DP-1, ...)
# und die Auflösung/Position sind Platzhalter — echte Werte per
#   swaymsg -t get_outputs
# ermitteln und hier eintragen, oder einfach nwg-displays einmal
# durchlaufen lassen und das generierte Profil übernehmen.
{
  pkgs,
  hostname,
  ...
}:

{
  home.packages = [
    pkgs.nwg-displays
  ];

  services.kanshi = {
    enable = true;
    settings =
      if hostname == "laptop" then
        [
          {
            profile.name = "undocked";
            profile.outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
                scale = 1.0;
              }
            ];
          }
          {
            profile.name = "docked";
            profile.outputs = [
              {
                criteria = "eDP-1"; # Laptop-Panel, unten
                status = "enable";
                # Y = Höhe des externen Monitors (unten drunter platziert).
                # Falls der externe Monitor nicht 1080px hoch ist, hier
                # anpassen (siehe Kommentar unten bei DP-1).
                position = "0,1080";
              }
              {
                criteria = "DP-1"; # externer Monitor, oben, zentriert.
                # Platzhalter — echten Namen per `swaymsg -t get_outputs`
                # prüfen und anpassen.
                status = "enable";
                # Zentrierung: X-Offset = (eigene Breite − Panel-Breite) / 2.
                # Bei gleicher Breite (hier: beide 1920) ist der Offset 0.
                # Falls der externe Monitor breiter/schmäler als das
                # Laptop-Panel ist, X entsprechend anpassen, damit er
                # mittig über eDP-1 sitzt statt bündig links.
                position = "0,0";
              }
            ];
          }
        ]
      else if hostname == "desktop" then
        [
          {
            # Feste 3-Monitor-Anordnung: HDMI-A-1 (links) — DP-1 (mittig)
            # — DP-3 (rechts, hochkant). Namen per `swaymsg -t get_outputs`
            # verifiziert (ändern sich normalerweise nicht, solange die
            # Kabel an denselben Ports bleiben).
            profile.name = "desktop";
            profile.outputs = [
              {
                criteria = "HDMI-A-1";
                status = "enable";
                position = "0,0";
              }
              {
                criteria = "DP-1";
                status = "enable";
                position = "1920,0";
              }
              {
                criteria = "DP-3";
                status = "enable";
                # Hochkant, nach links (gegen den Uhrzeigersinn) gedreht.
                # Falls die Ausrichtung falsch rum ist: auf "90" wechseln
                # (dreht stattdessen nach rechts/im Uhrzeigersinn).
                transform = "270";
                # 3840 = Summe der logischen Breiten von HDMI-A-1 (1920)
                # + DP-1 (1920), damit DP-3 direkt rechts daran anschließt.
                position = "3840,0";
              }
            ];
          }
        ]
      else
        [
          {
            profile.name = "default";
            profile.outputs = [
              {
                criteria = "*";
                status = "enable";
              }
            ];
          }
        ];
  };
}
