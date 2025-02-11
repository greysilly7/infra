{pkgs, ...}: {
  compress = pkgs.writeShellScriptBin "compress" (builtins.readFile ./scripts/compress.sh);
  extract = pkgs.writeShellScriptBin "extract" (builtins.readFile ./scripts/extract.sh);
}
