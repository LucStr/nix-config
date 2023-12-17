# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  # example = pkgs.callPackage ./example { };
  jb = pkgs.callPackage ./jb.nix { };
  mongodb-compass-luca = pkgs.callPackage ./mongodb-compass.nix { };
}
