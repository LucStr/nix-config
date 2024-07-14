# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  # example = pkgs.callPackage ./example { };
  jb = pkgs.callPackage ./jb.nix { };
  mongodb-compass-luca = pkgs.callPackage ./mongodb-compass.nix { };
  goldy-plasma-theme = pkgs.callPackage ./themes/goldy-plasma-themes.nix { };
  everforest-theme = pkgs.callPackage ./themes/everforest-themes.nix { };
  mongosync = pkgs.callPackage ./mongosync.nix { };
  dotnet-luca = pkgs.callPackage ./dotnet { };
  tuxedo-control-center = pkgs.callPackage ./tuxedo-control-center.nix { };
  ms-dotnettools-csdevkit = pkgs.callPackage ./ms-dotnettools.csdevkit { };
  ms-dotnettools-csharp = pkgs.callPackage ./ms-dotnettools.csharp { };
  rose-pine-xcursor = pkgs.callPackage ./cursor-themes/rose-pine-xcursor.nix { };
}
