{...}: {
  services.tabby = {
    enable = true;
    acceleration = "rocm";
  };
  networking.firewall.allowedTCPPorts = [11029];
}
