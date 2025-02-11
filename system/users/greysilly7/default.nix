{
  pkgs,
  config,
  ...
}: {
  sops.secrets.grey_pass.neededForUsers = true;

  users.users.greysilly7 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "systemd-journal"
      "audio"
      "video"
      "input"
      "lp"
      "networkmanager"
      "power"
      "nix"
      "adbusers"
    ];
    homix = true;
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets.grey_pass.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAUXpvCORVoy/X8nGp2dgrgpa50sAPv5IeQeTzjb5KR greysilly7@gmail.com"
    ];
  };
}
