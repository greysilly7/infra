{config, ...}: {
  services = {
    cloudflare-dyndns = {
      enable = true;
      apiTokenFile = config.sops.secrets.cftoken.path;
      ipv4 = true;
      ipv6 = true;
      proxied = true;
      domains = ["greysilly7.xyz"];
    };
    cloudflared = {
      enable = true;
      tunnels = {
        "00000000-0000-0000-0000-000000000000" = {
          credentialsFile = "${config.sops.secrets.cloudflared-creds.path}";
          default = "http_status:404";
        };
      };
    };
  };
}
