{
  config,
  lib,
  pkgs,
  ...
}:
{
  ##########################################################################
  ### Screen-Lock (swaylock) – ersetzt hyprlock
  ##########################################################################
  # PAM wird durch programs.sway.enable (NixOS-Modul) automatisch gesetzt.
  # Farben grob aus deiner hyprlock.conf gemappt.
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    # Alternative mit Blur/Screenshot-Effekten (Look näher an hyprlock):
    # package = pkgs.swaylock-effects;

    settings = {
      # Hintergrundbild wie hyprlock – Pfad an deine Repo-Struktur anpassen:
      image = "${../../wallpaper/lock.png}";
      color = "191414"; # hyprlock-BG rgba(25, 20, 20, 1.0)
      font-size = 24;
      indicator-radius = 100;
      indicator-thickness = 7;
      show-failed-attempts = true;

      # grob gemappt aus deiner hyprlock.conf:
      ring-color = "151515"; # outer_color rgb(151515)
      inside-color = "c8c8c8"; # inner_color rgb(200,200,200)
      text-color = "0a0a0a"; # font_color rgb(10,10,10)
      key-hl-color = "cc8822"; # check_color rgb(204,136,34)
      ring-ver-color = "cc8822";
      ring-wrong-color = "cc2222"; # fail_color rgb(204,34,34)
    };
  };

}
