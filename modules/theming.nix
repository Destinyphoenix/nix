# modules/theming.nix
#
# dconf wird von GTK4/libadwaita-Apps gebraucht, um den Dark-Mode-Zustand
# (org.gnome.desktop.interface color-scheme) dauerhaft zu speichern – ohne
# laufenden dconf-Dienst verpufft die Einstellung aus hm-modules/theming.nix
# bei jedem Login neu.
{
  programs.dconf.enable = true;
}
