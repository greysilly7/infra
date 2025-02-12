{pkgs, ...}: let
  inherit (builtins) attrValues;
in {
  imports = [
    ../system/users
    ../system/users/greysilly7
    ../system/nix
    ../system/net
    ../system/secrets

    # This is used for all my systems
    ../system/disks
    ../system/boot
    ../system/services/openssh.nix
  ];

  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Detroit";
  };

  # Internationalisation properties
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  environment.systemPackages = attrValues {
    inherit
      (pkgs)
      git
      ripgrep
      nmap
      grex
      jq
      rsync
      unzip
      zip
      dnsutils
      which
      udev
      wormhole-rs
      ;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [];
  programs.direnv.enable = true;

  services.udev.enable = true;

  system.stateVersion = "24.05";
}
