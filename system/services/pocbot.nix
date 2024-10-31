{
  config,
  pkgs,
  ...
}: let
  # Define the POCBot derivation
  pocbotPackage = pkgs.stdenv.mkDerivation rec {
    pname = "pocbot";
    version = "git";

    src = pkgs.fetchFromGitHub {
      owner = "OpenPlayVerse";
      repo = "POCBot";
      rev = "main"; # Specify the desired commit or branch
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with the actual sha256
    };

    buildInputs = [pkgs.rustc pkgs.cargo];

    buildPhase = ''
      cargo build --release
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp target/release/pocbot $out/bin/
    '';
  };
in {
  # Define the systemd service for POCBot
  systemd.services.pocbot = {
    description = "POCBot Service"; # Description of the service
    after = ["network.target"]; # Start after network is up
    wantedBy = ["multi-user.target"]; # Wanted by multi-user target

    # Service configuration
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.pocbot_token.path; # Path to environment file for secrets
      ExecStart = "${pocbotPackage}/bin/pocbot"; # Command to start the service
      Restart = "always"; # Always restart the service on failure
      User = "pocbot"; # Run the service as pocbot user
      Group = "pocbot"; # Run the service as pocbot group
    };
  };

  # Define the pocbot group
  users.groups.pocbot = {};

  # Define the pocbot user
  users.users.pocbot = {
    isSystemUser = true; # Define as a system user
    description = "POCBot User"; # Description of the user
    home = "/var/lib/pocbot"; # Home directory for the user
    group = "pocbot"; # Primary group for the user
    createHome = true; # Create home directory if it doesn't exist
  };
}
