{config, ...}: {
  sops = {
    # Path to the default SOPS file
    defaultSopsFile = ../../secrets/secrets.yaml;

    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true; # Generate a new key if not present
    };

    secrets = {
      # List of secrets managed by SOPS
      grey_pass = {};
      greyberet_pass = {};
      cftoken = {};
      vaultwarden = {};
      cf_acme = {};
      ts_srv_key = {};
      imagorenv = {};
      github_ci_token = {};
      pocbot_token = {
        /*
        owner = config.users.users.pocbot.name;
        group = config.users.users.pocbot.group;
        */
      };
      jankwrapper_secret_env = {
        /*
        owner = config.users.users.jankclient.name;
        group = config.users.users.jankclient.group;
        */
      };
    };
  };
}
