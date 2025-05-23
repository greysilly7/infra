{
  lib,
  pkgs,
  config,
  ...
}: let
  wingsConfig = ''
    # /etc/pterodactyl/configuration.yml managed by /etc/NixOS/wings.nix
  '';
  wingsBinary = pkgs.callPackage ../../pkgs/wings {};
in {
  environment.etc."pterodactyl/config.yml".text = wingsConfig;

  systemd.services.wings = {
    enable = true;
    description = "Pterodactyl Wings daemon";
    after = ["docker.service"];
    partOf = ["docker.service"];
    requires = ["docker.service"];
    startLimitIntervalSec = 180;
    startLimitBurst = 30;
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/run/wings";
      LimitNOFILE = 4096;
      PIDFile = "/run/wings/daemon.pid";
      ExecStart = "${lib.getExe pkgs.bash} -c '${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p /run/wings; ${pkgs.uutils-coreutils-noprefix}/bin/cat ${config.sops.secrets.wings.path} >> /run/wings/config.yml; ${wingsBinary}/bin/wings --config /run/wings/config.yml'";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    wantedBy = ["multi-user.target"];
    path = [pkgs.uutils-coreutils-noprefix pkgs.su];
  };

  users.users.pterodactyl = {
    isSystemUser = true;
    group = "pterodactyl";
    home = "/var/lib/pterodactyl";
    createHome = true;
    extraGroups = ["docker"];
  };
  users.groups.pterodactyl = {};
}
