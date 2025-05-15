{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pterodactyl-wings";
  version = "1.11.13";

  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "v${version}";
    sha256 = "sha256-EOkHi+x4ciODyHPPx7766IEh8XGLHY4Ng1N/iq2mgJI=";
  };

  vendorHash = "sha256-LR4JuV73BWhXI97HGNH93Hd5NMU9PD84Rqfz4GOJzUs=";
  subPackages = ["."];

  patches = [
    ./wings.patch
  ];

  ldflags = [
    "-X github.com/pterodactyl/wings/system.Version=${version}"
  ];
}
