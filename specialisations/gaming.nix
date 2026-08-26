{
  pkgs,
  lib,
  username,
  ...
}:
{

  specialisation = {
    gaming.configuration = {

      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
        };
        gamemode = {
          enable = true;
        };
        gamescope = {
          enable = true;
          capSysNice = true;
        };

      };
      hardware.steam-hardware.enable = true;
      # Clean Quiet Boot
      boot = {
        kernelParams = [
          "quiet"
          "splash"
          "loglevel=3"
          #"console=/dev/null"
          "amdgpu.gttsize=8192" # MB — increases GPU-addressable system RAM
        ];
        plymouth.enable = true;
      };

      # Gamescope Auto Boot from TTY (example)
      services = {
        xserver.enable = false; # Assuming no other Xserver needed
        #getty.autologinUser = "${username}";
        greetd = {
          #  enable = true;
          settings = {
            default_session = lib.mkForce {
              command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
              user = "${username}";
            };
          };
        };
      };

    };
  };
}
