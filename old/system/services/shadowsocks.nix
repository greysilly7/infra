{config, ...}: {
  services.shadowsocks = {
    enable = true;
    fastOpen = true;
    passwordFile = config.sops.secrets.shadowsocks_pass.path;
  };
}
