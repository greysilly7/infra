{lib, pkgs, ...}: let
  wingsConfig = ''
    # /etc/pterodactyl/configuration.yml managed by /etc/NixOS/wings.nix
  '' + builtins.readFile config.sops.wings.path;
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
      ExecStart = "${lib.getExe pkgs.bash} -c '/usr/bin/env mkdir /run/wings; /usr/bin/env cat /etc/pterodactyl/config.yml > /run/wings/config.yml; ${wingsBinary}/bin/wings --config /run/wings/config.yml'";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    wantedBy = ["multi-user.target"];
  };
}
