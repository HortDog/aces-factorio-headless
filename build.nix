let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ./aces-factorio-headless.nix {}