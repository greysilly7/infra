{...}: {
  imports = [
    ./net
    ./disks
    ./boot
    ./fonts
    ./audio
    ./users
    ./wayland
    ./nix
    ./secrets
    # ./security
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

  environment.etc.machine-id.text = "d3a2b82456e943bfa10df0a0cb4830fa";
  system.stateVersion = "24.05";
}