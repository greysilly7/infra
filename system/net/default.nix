{
  pkgs,
  config,
  ...
}: {
  networking = {
    # nameservers = ["127.0.0.1" "::1"];
    dhcpcd.extraConfig = "nohook resolv.conf";
    useNetworkd = true;
    networkmanager = {
      enable = true;
      unmanaged = ["docker0" "pterodactyl0"];
      # dns = "none";
      wifi = {
        macAddress = "random";
        powersave = true;
      };
    };
    firewall = {
      enable = true;
      allowPing = true;
      logReversePathDrops = true;
      logRefusedConnections = false;
      trustedInterfaces = ["docker0" "pterodactyl0"];
    };
  };

  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${pkgs.tailscale}/bin/tailscale up --auth-key=file:///run/secrets/ts_key --accept-routes
    '';
  };

  # slows down boot time
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };
}
