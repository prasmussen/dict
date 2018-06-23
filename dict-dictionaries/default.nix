{ pkgs ? import <nixpkgs> {} }:
let
  src =
    ./dictionaries;

  cmd =
    ''
    mkdir -p $out
    cp -rf ${src}/. $out/
    '';

in
pkgs.runCommand "dict-dictionaries" {} cmd
