{...}: {
  imports = [
    ./net
    ./disks
    ./boot
    ./fonts
    ./services
    ./users
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

  virtualisation.xen = {
    enable = true;
    efi.bootBuilderVerbosity = "info"; # Adds a handy report that lets you know which Xen boot entries were created.
    bootParams = [
      "vga=ask" # Useful for non-headless systems with screens bigger than 640x480.
      "dom0=pvh" # Uses the PVH virtualisation mode for the Domain 0, instead of PV.
    ];
    dom0Resources = {
      memory = 1024; # Only allocates 1GiB of memory to the Domain 0, with the rest of the system memory being freely available to other domains.
      maxMemory = 4096; # Allows the Domain 0 to balloon up to 4GiB of memory.
      maxVCPUs = 2; # Allows the Domain 0 to use, at most, two CPU cores.
    };
  };

  environment.etc.machine-id.text = "d3a2b82456e943bfa10df0a0cb4830fa";
  system.stateVersion = "24.05";
}
