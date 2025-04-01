{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pterodactyl-wings";
  version = "1.11.10";

  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "v${version}";
    sha256 = "sha256-EOkHi+x4ciODyHPPx7766IEh8XGLHY4Ng1N/iq2mgJI=";
  };

  vendorHash = "sha256-VApv+VSot/GmOyU3pBlOvHYG0oE3fCtTxN5F3PsYYf0=";
  subPackages = ["."];

  patches = [
    ./wings.patch
  ];

  ldflags = [
    "-X github.com/pterodactyl/wings/system.Version=${version}"
  ];
}
