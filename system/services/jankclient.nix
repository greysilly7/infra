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
      set -e
         ${pkgs.uutils-coreutils-noprefix}/bin/mkdir -p ${writableDir}/gitfiles
         ${pkgs.uutils-coreutils-noprefix}/bin/chown -R jankclient:jankclient ${writableDir}/gitfiles
         ${pkgs.uutils-coreutils-noprefix}/bin/chmod -R 755 ${writableDir}
         ${lib.getExe pkgs.rsync} -a ${inputs.jankclient}/* ${writableDir}/gitfiles
         ${pkgs.uutils-coreutils-noprefix}/bin/cp ${writableDir}/gitfiles/src/webpage/instances.json ${writableDir}
         ${lib.getExe pkgs.bun} install --cwd ${writableDir}/gitfiles --frozen-lockfile --backend=hardlink --verbose
         RANDOM_VALUE=$(${pkgs.uutils-coreutils-noprefix}/bin/head -c 16 /dev/urandom | ${pkgs.uutils-coreutils-noprefix}/bin/base64)
         ${lib.getExe pkgs.gnused} -i \
           's|const revision = .*|const revision = "'"$RANDOM_VALUE"'";|' \
           ${writableDir}/gitfiles/build.ts
         ${lib.getExe pkgs.bun} run bunBuild --cwd ${writableDir}/gitfiles
    '';

    script = "${lib.getExe pkgs.bun} ${writableDir}/gitfiles/dist/index.js";
    path = [pkgs.bun pkgs.git];

    serviceConfig = {
      WorkingDirectory = "${writableDir}/gitfiles";
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      EnvironmentFile = config.sops.secrets.jankwrapper_secret_env.path;
      RestartSec = "5s";
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
