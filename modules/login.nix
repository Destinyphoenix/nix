# modules/greetd.nix
#
# Ersetzt lightdm (X11) durch greetd + tuigreet, den Standard-Login-Manager
# für Wayland-Compositors. Startet Sway direkt aus der Login-Session heraus,
# statt vorher schon graphical-session.target zu aktivieren – das war die
# Ursache für den ConditionEnvironment=WAYLAND_DISPLAY-Fehler bei wpaperd.
{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd sway";
        user = "greeter";
      };
    };
  };
}
