{
  lib,
  modulesPath,
  flake,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/base-server.nix
    ../../system/users/greyberet
    ../../system/services/pterodactyl-wings.nix
  ];
  facter.reportPath = ./facter.json;

  system.autoUpgrade = {
    enable = true;
    flake = flake.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "daily";
    randomizedDelaySec = "45min";
  };

  # Allow minecraft in firewall
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 25565;
        to = 25600;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 25565;
        to = 25600;
      }
    ];
  };

  services.cloudflared = {
    enable = true;
    package = pkgs.callPackage ../../pkgs/cloudflared.nix {};
    tunnels = {
      "Wings_MCServer" = {
        credentialsFile = "${config.sops.secrets.cloudflared-creds.path}";
        default = "http_status:404";
      };
    };
  };

  virtualisation.incus.agent.enable = true;

  # 8100 - Bluemap
  # 24454 - SimpleVoiceChat Proxy
  # 37429 - SimpleVoiceChat Survival
  # 49210 - SimpleVoiceChat Creative
  # 24554 - SimpleVoiceChat Lobby
  # 19132 - Geyser
  #
  # 25565 - Velocity
  # 25560 - Survival
  # 25561 - Creative
  # 25562 - Lobby
}
