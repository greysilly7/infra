{
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (builtins) attrValues;
in {
  environment.systemPackages = attrValues {
    inherit
      (pkgs)
      git
      ripgrep
      zoxide
      fzf
      eza
      bat
      gping
      dogdns
      ffmpeg-full
      nmap
      grex
      jq
      rsync
      unzip
      zip
      dnsutils
      which
      nixd
      alejandra
      ;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [];
  programs.direnv.enable = true;
}
