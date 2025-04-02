{
  pkgs,
  config,
  ...
}: {
  services = {
    cloudflare-dyndns = {
      enable = true;
      apiTokenFile = config.sops.secrets.cftoken.path;
      ipv4 = true;
      ipv6 = true;
      proxied = true;
      domains = ["greysilly7.xyz"];
    };
  };
}
