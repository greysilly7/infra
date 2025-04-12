{pkgs, ...}: {
  users = {
    mutableUsers = false;
    users = {
      root = {
        password = "temp";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrFiy0QMKHdyucTJTC3OJXO9EWyqf1IqYB1zWipTI+1 github-actions-deploy"
        ];
      };
    };
  };

  security = {
    sudo-rs = {
      enable = true;
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
    /*
    sudo = {
      enable = true;
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
    */

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
