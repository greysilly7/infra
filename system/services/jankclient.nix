{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  writableDir = "/var/lib/jankclient";
in {
  systemd.services.jankclient = {
    description = "Jank Client Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      # TODO: Make this less jank
      JANKK_DIR = "${writableDir}/gitfiles";
      NODE_ENV = "production";
    };

    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${lib.getExe pkgs.bun} install
      ${lib.getExe pkgs.bun} gulp --swc
    '';

    # script = "${inputs.jankwrapper.packages.${pkgs.system}.default}/bin/jankwrapper";
    script = "${lib.getExe pkgs.bun} ${writableDir}/gitfiles/dist/index.js";
    path = [pkgs.nodejs_latest pkgs.bun pkgs.git];

    serviceConfig = {
      WorkingDirectory = writableDir;
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      EnvironmentFile = config.sops.secrets.jankwrapper_secret_env.path; # Path to environment file for secrets
    };
  };

  systemd.tmpfiles.rules = [
    "d ${writableDir} 0755 jankclient jankclient - -"
  ];

  users.users.jankclient = {
    isSystemUser = true;
    group = "jankclient";
    home = writableDir;
  };

  users.groups.jankclient = {};
}
