{ pkgs ? import <nixpkgs> {} }:
let
  src =
    ./files;

  cmd =
    ''
    mkdir -p $out
    cp -rf ${src}/. $out/
    '';

in
pkgs.runCommand "dict-static" {} cmd
