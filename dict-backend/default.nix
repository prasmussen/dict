{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoPackage rec {
  name = "dict-backend-${version}";
  version = "2018-06-21";
  rev = "51882fe0198a88bb177f2dcd7a7d5f84e03a2256";

  goPackagePath = "github.com/prasmussen/dict";

  src = pkgs.fetchgit {
    rev = rev;
    url = "https://github.com/prasmussen/dict";
    sha256 = "1yv9ik14m9zi8dvx97nfa6rsnpfw6csdqq0s28268ik9jyr9by2k";
  };

  goDeps = ./deps.nix;
}
