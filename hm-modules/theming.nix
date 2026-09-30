# hm-modules/theming.nix
#
# GTK- und Qt-Theming aus einer Hand, damit auch Qt-Apps (z.B. qBittorrent,
# Kdenlive, qt5ct-Konsumenten) nicht wie ein Fremdkörper neben Sway/GTK
# aussehen:
#   - GTK2/3/4 laufen im Adwaita-Dark-Look, Dark-Mode-Präferenz per dconf
#     (color-scheme=prefer-dark), damit auch libadwaita/GTK4-Apps mitziehen.
#   - Qt5/6-Apps lesen ihr Theme über qt5ct/qt6ct (qt.platformTheme) und
#     rendern es mit der Kvantum-Engine (qt.style). KvGnomeDark ist ein in
#     qtstyleplugin-kvantum mitgeliefertes Theme, keine externe Abhängigkeit.
#
# theme.nix (Farb-Tokens) lässt sich hier nicht einspeisen – Adwaita/Kvantum
# sind fertige Theme-Pakete ohne Token-Schnittstelle, nur Font/Size ziehen
# aus theme.nix.
{ pkgs, theme, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    colorScheme = "dark";
    font = {
      name = theme.font;
      size = theme.fontSize;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct"; # Qt-Apps lesen ihr Theme aus qt5ct/qt6ct statt GTK zu emulieren
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=KvGnomeDark
  '';
}
