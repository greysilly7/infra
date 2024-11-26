{
  pkgs,
  lib,
  ...
}: let
  jankClientSrc = pkgs.fetchFromGitHub {
    owner = "MathMan05";
    repo = "JankClient";
    rev = "main";
    sha256 = "sha256-8Hd8TFktyZlFGZ9Psjxbga7gXKChMtSbteJZtIhG+Og=";
  };

  writableDir = "/var/lib/jankclient";
in {
  systemd.services.jankClient = {
    description = "Jank Client Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}
      ${pkgs.coreutils}/bin/cp -a -r ${jankClientSrc}/* ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${pkgs.bun}/bin/bun install
      ${pkgs.bun}/bin/bun x gulp --swc
    '';
    script = "${pkgs.bun}/bin/bun ${writableDir}/dist/index.js";
    path = [pkgs.nodejs_latest];

    serviceConfig = {
      WorkingDirectory = writableDir;
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      Environment = ["NODE_ENV=production"];
    };
  };

  users.users.jankclient = {
    isSystemUser = true;
    group = "jankclient";
    home = writableDir;
  };

  users.groups.jankclient = {};
}
