{pkgs, ...}: let
  # Fetch and build the JankClient source code from GitHub
  jankClientPackage = pkgs.stdenv.mkDerivation rec {
    pname = "jankclient";
    version = "git";

    src = pkgs.fetchFromGitHub {
      owner = "MathMan05";
      repo = "JankClient";
      rev = "main"; # Specify the desired commit or branch
      sha256 = "sha256-EzRADfKD5YwCepMp6dz8IgZG7y5gXvJKQpHwPLm0GMI="; # Replace with the actual sha256
    };

    buildInputs = [pkgs.bun pkgs.nodejs];

    buildPhase = ''
      ${pkgs.bun}/bin/bun install
      ${pkgs.bun}/bin/bun run gulp --swc
    '';

    installPhase = ''
      mkdir -p $out/dist
      cp -r dist/* $out/dist/
      ln -s /var/lib/jankclient/uptime.json $out/dist/uptime.json
    '';
  };
in {
  # Ensure the /var/lib/jankclient directory and uptime.json file exist
  system.activationScripts.jankClient = ''
    mkdir -p /var/lib/jankclient
    echo '{"Fastbar":[{"time":1726856179273,"online":true},{"time":1728270066546,"online":false},{"time":1728280072366,"online":true},{"time":1729774472489,"online":false},{"time":1729792986590,"online":true},{"time":1729879611607,"online":false},{"time":1729882986743,"online":true}],"Spacebar":[{"time":1726856179640,"online":true},{"time":1727191619620,"online":false},{"time":1727359659118,"online":true},{"time":1728247397893,"online":false},{"time":1728279651457,"online":true},{"time":1728333788401,"online":false},{"time":1728504605878,"online":true},{"time":1729881266639,"online":false},{"time":1729882847154,"online":true}],"Vanilla Minigames":[{"time":1726856180055,"online":true},{"time":1728248263538,"online":false},{"time":1728279991199,"online":true},{"time":1728334125297,"online":false},{"time":1728504606984,"online":true},{"time":1729879703683,"online":false},{"time":1729883084179,"online":true}]}' > /var/lib/jankclient/uptime.json
    chown jankclient:jankclient /var/lib/jankclient/uptime.json
    chmod 664 /var/lib/jankclient/uptime.json
  '';

  # Define the systemd service for JankClient
  systemd.services.jankClient = {
    description = "JankClient Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    script = "${pkgs.bun}/bin/bun ${jankClientPackage}/dist/index.js";

    serviceConfig = {
      WorkingDirectory = "${jankClientPackage}/dist";
      Restart = "always";
      User = "jankclient";
      Group = "jankclient";
      Environment = "NODE_ENV=production";
    };

    path = with pkgs; [coreutils bun nodejs];
  };

  # Define the jankclient user and group
  users.users.jankclient = {
    isSystemUser = true;
    group = "jankclient";
    home = "/var/empty";
  };

  users.groups.jankclient = {};
}
