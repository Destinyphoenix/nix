{ pkgs, lib, ... }:
{

  specialisation = {
    gaming.configuration = {

      programs = {
        # gamescope = {
        #   enable = true;
        #   capSysNice = true;
        # };
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
        gamemode = {
          enable = true;
        };
        gamescope = {
          enable = true;
          capSysNice = true;
        };

      };

      # Clean Quiet Boot
      boot = {
        kernelParams = [
          "quiet"
          "splash"
          "console=/dev/null"
        ];
        plymouth.enable = true;
      };

      # Gamescope Auto Boot from TTY (example)
      services = {
        xserver.enable = false; # Assuming no other Xserver needed
        getty.autologinUser = "phoenix";
        greetd = {
          enable = true;
          settings = {
            default_session = lib.mkForce {
              command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
              user = "phoenix";
            };
          };
        };
      };

    };
  };
}
