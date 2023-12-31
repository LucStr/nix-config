# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  # example = pkgs.callPackage ./example { };
  jb = pkgs.callPackage ./jb.nix { };
  mongodb-compass-luca = pkgs.callPackage ./mongodb-compass.nix { };
  goldy-plasma-theme = pkgs.callPackage ./themes/goldy-plasma-themes.nix { };
  everforest-theme = pkgs.callPackage ./themes/everforest-themes.nix { };
  mongosync = pkgs.callPackage ./mongosync.nix { };
}
