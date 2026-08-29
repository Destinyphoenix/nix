{
  pkgs,
  username,
  ...
}:

{
  virtualisation.docker = {
    enable = true;

    # Optional: Docker als Rootless-Dienst betreiben
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    ctop
  ];

  users.users.${username}.extraGroups = [ "docker" ];
}
