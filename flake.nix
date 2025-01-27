{
  description = "My nix infrastructure";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:CertainLach/lanzaboote/feat/xen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Build Inputs
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    user = import ./user {
      inherit pkgs;
      flake = self;
    };
  in {
    nixosConfigurations = import ./hosts inputs;
    nixosModules =
      {
        system = import ./system;
        user = user.module;
        disko = inputs.disko.nixosModules.default;
        sops-nix = inputs.sops-nix.nixosModules.sops;
      }
      // import ./modules;

    formatter.x86_64-linux = pkgs.alejandra;
  };
}
