{pkgs, ...}: {
  users = {
    mutableUsers = false;
    users = {
      root.password = "temp";
    };
  };

  security = {
    sudo = {
      enable = true;
      package = pkgs.sudo-rs;
      extraRules = [
        {
          commands =
            builtins.map (command: {
              command = "/run/current-system/sw/bin/${command}";
              options = ["NOPASSWD"];
            })
            ["poweroff" "reboot" "nixos-rebuild" "nix-env" "bandwhich" "systemctl"];
          groups = ["wheel"];
        }
      ];
    };

    pam = {
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];
    };
  };
}
