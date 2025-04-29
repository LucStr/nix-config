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
    #(jetbrains.plugins.addPlugins jetbrains.rider [ "github-copilot" "ideavim" ])
    jetbrains.rider
    jb
  ];

  environment.sessionVariables = {
    "DOTNET_ROOT" = "${dotnet-combined.outPath}/share/dotnet";
  };
}
