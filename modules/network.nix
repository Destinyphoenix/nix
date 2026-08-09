{ pkgs, username, ... }:

# Zentrales Netzwerk-Modul – bündelt ALLE netzwerkbezogenen Einstellungen
# (System- und Home-Manager-Ebene) an einem Ort.
# Möglich, weil Home Manager als NixOS-Modul eingebunden ist
# (home-manager.nixosModules.home-manager in flake.nix) -> HM-Optionen
# lassen sich hier über home-manager.users.${username} setzen.
{
  ####################################################################
  ### System-Ebene (NixOS)
  ####################################################################
  networking = {
    hostName = "nixos";

    # NetworkManager als Backend (WLAN, LAN, VPN, Roaming).
    networkmanager = {
      enable = true;

      # Optional: iwd als WLAN-Backend (schnelleres/robusteres Scannen).
      # Achtung: wechselt das WLAN-Backend – ggf. gespeicherte Netze neu
      # einrichten. Zum Aktivieren einkommentieren:
      # wifi.backend = "iwd";

      # Optional: WLAN-Stromsparen aus (weniger Verbindungsabbrüche):
      # wifi.powersave = false;
    };

    # wpa_supplicant NICHT aktivieren – kollidiert mit NetworkManager:
    # wireless.enable = true;

    # Firewall ist standardmäßig an. Ports bei Bedarf öffnen:
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ];
      # allowedUDPPorts = [ ];
    };
  };

  # Nutzer darf NetworkManager verwalten (Netze anlegen/ändern/verbinden).
  # Wird mit den übrigen Gruppen gemerged.
  users.users.${username}.extraGroups = [ "networkmanager" ];

  ####################################################################
  ### Home-Manager-Ebene (Frontend zum Verbinden)
  ####################################################################
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      networkmanager_dmenu # tofi-basierter WLAN-Picker
      networkmanagerapplet # liefert nm-connection-editor (Detail-Bearbeitung)
    ];

    # networkmanager_dmenu nutzt tofi als Menü (native tofi-Unterstützung).
    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = tofi --config /home/${username}/.config/tofi/network
    '';

    # WLAN-Picker aufrufen. Wird in die Sway-keybindings gemerged (attrsOf).
    #wayland.windowManager.sway.config.keybindings."Mod4+n" = "exec networkmanager_dmenu";
  };
}
