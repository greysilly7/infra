{
  lib,
  modulesPath,
  flake,
  config,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../modules/base-server.nix
    ../../system/users/greyberet
    ../../system/services/pterodactyl-wings.nix
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "xhci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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

  # 8100 - Bluemap
  # 24454 - SimpleVoiceChat Proxy
  # 37429 - SimpleVoiceChat Survival
  # 49210 - SimpleVoiceChat Creative
  # 24554 - SimpleVoiceChat Lobby
  # 19132 - Geyser
  #
  # 2`5565 - Velocity
  # 2`5560 - Survival
  # 2`5561 - Creative
  # 2`5562 - Lobby
}
