{ system ? builtins.currentSystem }:

let
  flake = import ./..;
  inherit (flake.inputs.nixpkgs) lib;
in
# Return all declared packages matching the current system
lib.attrByPath [ system ] { } flake.packages
