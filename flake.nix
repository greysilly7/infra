{
  description = "My nix infrastructure";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    # jankwrapper = {
    #   url = "github:greysilly7/jankwrapper";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-topology.url = "github:oddlama/nix-topology";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [inputs.nix-topology.overlays.default];
    };
  in {
    nixosConfigurations = import ./hosts inputs;
    nixosModules = {
      disko = inputs.disko.nixosModules.default;
      sops-nix = inputs.sops-nix.nixosModules.sops;
      lix = inputs.lix-module.nixosModules.default;

      nix-topology = inputs.nix-topology.nixosModules.default;
    };
    formatter.x86_64-linux = pkgs.alejandra;

    topology.x86_64-linux = import inputs.nix-topology {
      inherit pkgs; # Only this package set must include nix-topology.overlays.default
      modules = [
        # Your own file to define global topology. Works in principle like a nixos module but uses different options.
        ./topology.nix
        # Inline module to inform topology of your existing NixOS hosts.
        {nixosConfigurations = self.nixosConfigurations;}
      ];
    };
  };
}
