{
  pkgs,
  theme,
  ...
}: rec {
  packages = let
    inherit (pkgs) callPackage;
  in {
    cli =
      {
        zsh = callPackage ./zsh {};
      }
      // (import ./misc-scripts {inherit pkgs;});
  };

  shell = pkgs.mkShell {
    name = "greysilly7-devshell";
    buildInputs = builtins.attrValues packages.cli;
  };

  module = {
    config = {
      environment.systemPackages = builtins.concatLists (map (x: builtins.attrValues x) (builtins.attrValues packages));
    };
    imports = [
      ./packages.nix
      ./git
    ];
  };
}
