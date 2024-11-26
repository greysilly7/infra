{
  config,
  pkgs,
  ...
}: {
  services.vaultwarden = {
    enable = true;
    package = pkgs.vaultwarden-postgresql;
    dbBackend = "postgresql";

    environmentFile = config.sops.secrets.vaultwarden.path;
    # dbBackend = "postgresql";

    config = {
      DOMAIN = "https://vaultwarden.greysilly7.xyz";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      USE_SYSLOG = true;
      INVITATIONS_ALLOWED = true;
      IP_HEADER = "X-Real-IP";
      SIGNUPS_ALLOWED = false;
      LOG_LEVEL = "info";
      ROCKET_LOG = "info";

      DATABASE_URL = "postgresql://vaultwarden@127.0.0.1:5432/vaultwarden";
    };
  };
}
