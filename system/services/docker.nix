{...}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "btrfs";
    rootless = {
      enable = false;
      setSocketVariable = true;
    };
  };
}
