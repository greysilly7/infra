{
  description = "My nix infrastructure";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal Projects
    greysilly7-xyz = {
      url = "github:greysilly7/greysilly7.xyz";
      flake = false;
    };
    spacebarchat = {
      url = "github:greysilly7/server/fastbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pocbot = {
      url = "github:OpenPlayVerse/POCBot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jankclient = {
      url = "github:mathman05/jankclient";
      flake = false;
    };
    mc_tools = {
      url = "github:greysilly7/mc_tools";
    };
    # jankwrapper = {
    #   url = "github:greysilly7/jankwrapper";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    nixosConfigurations = import ./hosts inputs;
    nixosModules = {
      disko = inputs.disko.nixosModules.default;
      sops-nix = inputs.sops-nix.nixosModules.sops;
      # lix = inputs.lix-module.nixosModules.default;
      homix = import ./modules/homix;
    };
    deploy.nodes = {
      greyserver = {
        hostname = "greyserver";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.greyserver;
        };
      };
    };
    formatter.x86_64-linux = pkgs.alejandra;

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
