{ pkgs, lib, ... }:
{
  specialisation.gaming.configuration = {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    # Wie in 17daa4a (dort lief es): greetd startet gamescope+Steam direkt als
    # Nutzer, ohne tuigreet dazwischen – also Auto-Login ins steam-Konto.
    services.greetd.settings.default_session = lib.mkForce {
      command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
      user = "steam";
    };
  };
}
