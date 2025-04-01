{pkgs}: let
wingsConfig = {
  # /etc/pterodactyl/configuration.yml managed by /etc/NixOS/wings.nix
};
in {
environment.etc."pterodactyl/config.yml".text = wingsConfig;

    systemd.services.wings = {
      enable = cfg.enable;
      description = "Pterodactyl Wings daemon";
      after = [ "docker.service" ];
      partOf = [ "docker.service" ];
      requires = [ "docker.service" ];
      startLimitIntervalSec = 180;
      startLimitBurst = 30;
      serviceConfig = {
        User = "root";
        WorkingDirectory = "/run/wings";
        LimitNOFILE = 4096;
        PIDFile = "/var/run/wings/daemon.pid";
        ExecStart =
          "/bin/sh -c '/usr/bin/env mkdir /run/wings; /usr/bin/env cat /etc/pterodactyl/config.yml > /run/wings/config.yml; ${pkgs.callPackage ../../pkgs/wings}/bin/wings --config /run/wings/config.yml'";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      wantedBy = [ "multi-user.target" ];
    };
}