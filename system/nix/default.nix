{pkgs, ...}: {
  nix = {
    gc.automatic = false;
    package = pkgs.lix;
    channel.enable = false;

    settings = {
      flake-registry = "/etc/nix/registry.json";
      auto-optimise-store = true;
      # use binary cache, its not gentoo
      builders-use-substitutes = true;
      # allow sudo users to mark the following values as trusted
      allowed-users = ["@wheel" "root"];
      trusted-users = ["@wheel" "root"];
      commit-lockfile-summary = "chore: Update flake.lock";
      accept-flake-config = true;
      keep-derivations = true;
      keep-outputs = true;
      warn-dirty = false;

      sandbox = true;
      max-jobs = "auto";
      # continue building derivations if one fails
      keep-going = false;
      log-lines = 20;
      extra-experimental-features = ["flakes" "nix-command" "recursive-nix" "ca-derivations"];

      # use binary cache, its not gentoo
      substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/greysilly7/infra";
  };

  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  # this makes rebuilds little faster
  system.switch = {
    enable = false;
    enableNg = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
