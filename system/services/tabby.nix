{pkgs, ...}: let
  tabby = pkgs.tabby.overrideAttrs (finalAttrs: previousAttrs: {
    buildInputs = previousAttrs.buildInputs ++ [pkgs.cmake];
  });
in {
  services.tabby = {
    enable = true;
    acceleration = "rocm";
    package = tabby;
  };
  networking.firewall.allowedTCPPorts = [11029];
  environment.systemPackages = [pkgs.cmake];
}
