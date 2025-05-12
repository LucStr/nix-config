{pkgs, username, ...}:
let
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_9_0
  ]);
in
{
  users.users.${username}.packages = with pkgs; [
    dotnet-combined
    jetbrains.rider
    #(jetbrains.plugins.addPlugins jetbrains.rider [ "github-copilot" ])
    #(pkgs.stdenv.mkDerivation {
      #    name = "csharpier";
      #  version = "2.1.2";
      #  src = pkgs.fetchurl {
      #    url    = "https://downloads.marketplace.jetbrains.com/files/18243/720382/csharpier-2.1.2.zip";
      #    hash   = "sha256-IfFq+XsjApZcQcjXAZf0ta0q0lduOg5oAKXyAE77Lcg=";
      #  };
      #  dontUnpack = true;
      #  nativeBuildInputs = [ unzip ];
    #  installPhase = ''
    #      mkdir -p $out
    #      unzip $src
    #      cp -r csharpier/* $out
    #    '';
    #  })])
    jb
  ];

  environment.sessionVariables = {
    "DOTNET_ROOT" = "${dotnet-combined.outPath}/share/dotnet";
  };
}
