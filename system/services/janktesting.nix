{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  writableDir = "/var/lib/janktesting";
in {
  systemd.services.janktesting = {
    description = "Jank Client Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      JANKK_DIR = writableDir;
      NODE_ENV = "production";
      PORT = "101052";
    };

    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
    '';

    script = "${inputs.jankwrapper.packages.${pkgs.system}.default}/bin/jankwrapper";
    path = [pkgs.nodejs_latest pkgs.bun pkgs.git];

    serviceConfig = {
      WorkingDirectory = writableDir;
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      EnvironmentFile = config.sops.secrets.jankwrapper_secret_env.path; # Path to environment file for secrets
    };
  };

  users.users.jankclient = {
    isSystemUser = true;
    group = "jankclient";
    home = writableDir;
  };

  users.groups.jankclient = {};
  systemd.tmpfiles.rules = [
    "d ${writableDir} 0755 jankclient jankclient - -"
  ];
}
