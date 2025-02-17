{pkgs, ...}: {
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful other development tools
  environment.systemPackages = [
    pkgs.dive # look into docker image layers
    pkgs.podman-tui # status of containers in the terminal
    #pkgs.docker-compose # start group of containers for dev
    pkgs.podman-compose # start group of containers for dev
  ];

  services.dbus.enable = true;
}
