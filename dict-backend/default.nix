{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoPackage rec {
  name = "dict-backend-${version}";
  version = "2018-06-21";
  rev = "02e898b6b0850ea37046e85bfecb5a84651d395a";

  goPackagePath = "github.com/prasmussen/dict";

  src = pkgs.fetchgit {
    rev = rev;
    url = "https://github.com/prasmussen/dict";
    sha256 = "1al2613znb2898571r1fy1jia7limd6r8vqmxrs2hs2zny5pz8mx";
  };

  goDeps = ./deps.nix;
}
