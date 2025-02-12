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
      NODE_ENV = "production";
      JANK_UPTIME_JSON_PATH = "${writableDir}/uptime.json";
      JANK_INSTANCES_PATH = "${writableDir}/instances.json";
    };

    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}/gitfiles
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/cp -r ${inputs.jankclient}/* ${writableDir}/gitfiles
      ${lib.getExe pkgs.bun} install --cwd ${writableDir}/gitfiles
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${lib.getExe pkgs.bun} gulp --cwd ${writableDir}/gitfiles --swc
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
    '';

    # script = "${inputs.jankwrapper.packages.${pkgs.system}.default}/bin/jankwrapper";
    script = "${lib.getExe pkgs.bun} ${writableDir}/gitfiles/dist/index.js";
    path = [pkgs.nodejs_latest pkgs.bun pkgs.git];

    serviceConfig = {
      WorkingDirectory = "${writableDir}/gitfiles";
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
}
