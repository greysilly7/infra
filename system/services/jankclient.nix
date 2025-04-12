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
      ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p ${writableDir}/gitfiles
      ${pkgs.uutils-coreutils-noprefix}/bin/chown -R jankclient:jankclient ${writableDir}/gitfiles
      ${pkgs.uutils-coreutils-noprefix}/bin/chmod -R 755 ${writableDir}
      ${lib.getExe pkgs.rsync} -a ${inputs.jankclient}/* ${writableDir}/gitfiles
      ${pkgs.uutils-coreutils-noprefix}/bin/cp ${writableDir}/gitfiles/src/webpage/instances.json ${writableDir}
      ${lib.getExe pkgs.bun} install --cwd ${writableDir}/gitfiles --frozen-lockfile --backend=hardlink --verbose
      ${lib.getExe pkgs.gnused} -i '/gulp.task("commit",/,/});/d' ${writableDir}/gitfiles/gulpfile.cjs
      # Generate a random value and populate the file
      RANDOM_VALUE=$(${pkgs.uutils-coreutils-noprefix}/bin/head -c 16 /dev/urandom | ${pkgs.uutils-coreutils-noprefix}/bin/base64)
      ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p ${writableDir}/gitfiles/dist/webpage
      echo "$RANDOM_VALUE" > ${writableDir}/gitfiles/dist/webpage/getupdates
      ${lib.getExe pkgs.bun} gulp --cwd ${writableDir}/gitfiles --swc
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
