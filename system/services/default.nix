{...}: {
  imports = [
    ./spacebarchat
    ./caddy.nix
    ./cloudflared.nix
    ./docker.nix
    ./jankclient.nix
    ./openssh.nix
    ./pocbot.nix
    ./postgres.nix
    ./vaultwarden.nix
    ./shadowsocks.nix
    # ./tabby.nix
  ];
}
