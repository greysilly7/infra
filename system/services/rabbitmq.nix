{...}: {
  services.rabbitmq = {
    listenAddress = "0.0.0.0";
  };

  # Open firewall
  networking.firewall.allowedTCPPorts = [5672];
}
