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
      # TODO: Make this less jank
      JANKK_DIR = "${writableDir}/gitfiles";
      NODE_ENV = "production";
      PORT = "65532";
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

  systemd.tmpfiles.rules = [
    "d ${writableDir} 0755 jankclient jankclient - -"
  ];
}
