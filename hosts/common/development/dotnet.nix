{pkgs, username, inputs, lib, config, ...}:
let
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
      sdk_9_0
      sdk_10_0
  ]);

  plugins = inputs.nix-jetbrains-plugins.plugins.${pkgs.system};
  ideWithPlugins = jetbrains: ide-name: plugin-ids:
    let 
      ide = jetbrains."${ide-name}";
      processPlugin = 
        plugin:
        if lib.isDerivation plugin then
          plugin
        else if jetbrains.plugins.raw.byId ? "${plugin}" || jetbrains.plugins.raw.byName ? "${plugin}" then
          plugin
        else if plugins."${ide-name}"."${ide.version}" ? "${plugin}" then
          plugins."${ide-name}"."${ide.version}"."${plugin}"
        else
          throw "Could not resolve plugin ${plugin}";

      mappedPlugins = map processPlugin plugin-ids;
    in 
      jetbrains.plugins.addPlugins ide mappedPlugins;
in
{
  users.users.${username}.packages = with pkgs; [
    dotnet-combined
    #jetbrains.rider
    (ideWithPlugins jetbrains "rider" [
      "17718" # github-copilot
      "com.intellij.csharpier"
      "verify-rider"
    ])
    # (jetbrains.plugins.addPlugins jetbrains.rider [ 
    #   "17718"
    #   inputs.nix-jetbrains-plugins.plugins.${pkgs.system}.rider."2025.2.5"."com.intellij.csharpier"
    #   inputs.nix-jetbrains-plugins.plugins.${pkgs.system}.rider."2025.2.5"."verify-rider"
    # ])
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
