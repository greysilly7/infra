{
  pkgs,
  lib,
  ...
}: let
  # Fetch the JankClient source code from GitHub
  jankClientSrc = pkgs.fetchFromGitHub {
    owner = "MathMan05";
    repo = "JankClient";
    rev = "main"; # You can specify a specific commit or branch
    sha256 = "sha256-dRLTgPga5Z19Hz6s2Fy9pIiMwCQ3wb69MxYlHAFzDgc="; # lib.fakeSha256;
  };

  # Define the writable directory for JankClient
  writableDir = "/var/lib/jankclient";
in {
  # Define the systemd service for JankClient
  systemd.services.jankClient = {
    description = "Jank Client Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    # Pre-start script to set up the environment
    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${writableDir}
      ${pkgs.coreutils}/bin/cp -a -r ${jankClientSrc}/* ${writableDir}
      ${pkgs.coreutils}/bin/chown -R jankclient:jankclient ${writableDir}
      ${pkgs.coreutils}/bin/chmod -R 755 ${writableDir}
      ${pkgs.bun}/bin/bun install
      ${pkgs.bun}/bin/bun x gulp --swc
    '';

    # Script to run the JankClient
    script = "${pkgs.bun}/bin/bun ${writableDir}/dist/index.js";

    # Service configuration
    serviceConfig = {
      WorkingDirectory = "${writableDir}";
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      Environment = [
        "NODE_ENV=production"
      ];
    };

    # Add necessary packages to the PATH
    path = with pkgs; [coreutils bun nodejs_latest];
  };

  # Define the jankclient user
  users.users.jankclient = {
    isSystemUser = true;
    group = "jankclient";
    home = writableDir;
  };

  # Define the jankclient group
  users.groups.jankclient = {};

  # Define tmpfiles rules for the writable directory
  systemd.tmpfiles.rules = [
    "d ${writableDir} 0755 jankclient jankclient -"
  ];
}
