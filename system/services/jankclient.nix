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
      whoami
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}/gitfiles
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}/gitfiles
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${lib.getExe pkgs.rsync} -a ${inputs.jankclient}/* ${writableDir}/gitfiles
      ${pkgs.coreutils}/bin/cp ${writableDir}/gitfiles/src/webpage/instances.json ${writableDir}
      ${lib.getExe pkgs.bun} install --cwd ${writableDir}/gitfiles --frozen-lockfile --backend=hardlink --verbose
      ${lib.getExe pkgs.bun} gulp --cwd ${writableDir}/gitfiles --swc
      ${pkgs.coreutils}/bin/sed -i '/gulp.task("commit",/,/});/d' ${writableDir}/gitfiles/gulpfile.cjs
    '';

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
    uid = null;
    group = "jankclient";
    home = writableDir;
  };

  users.groups.jankclient = {};
}
