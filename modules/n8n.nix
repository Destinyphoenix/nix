{ ... }:
{
  services.n8n = {
    enable = true;
    environment = {
      GENERIC_TIMEZONE = "America/New_York";
      N8N_PORT = "5678";
      # Use _FILE suffix for secrets to load via systemd credentials
      DB_POSTGRESDB_PASSWORD_FILE = "/run/secrets/db_password";
    };
    openFirewall = true; # Open the port in the firewall
  };
}
