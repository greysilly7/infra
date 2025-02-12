{lib, ...}: {
  config = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        # Root user is used for remote deployment, so we need to allow it
        PermitRootLogin = lib.mkForce "prohibit-password";
        # Disable password login
        PasswordAuthentication = lib.mkForce false;
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
        UseDns = false;
        StreamLocalBindUnlink = true;
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # Add terminfo database of all known terminals to the system profile.
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/terminfo.nix
    environment.enableAllTerminfo = true;
  };
}
