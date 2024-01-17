/*
How to combine packages for use in development:
dotnetCombined = with dotnetCorePackages; combinePackages [ sdk_6_0 aspnetcore_7_0 ];

Hashes and urls are retrieved from:
https://dotnet.microsoft.com/download/dotnet
*/
{ lib, config, callPackage }:
let
  buildDotnet = attrs: callPackage (import ./build-dotnet.nix attrs) {};
  buildAttrs = {
    buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
    buildNetRuntime = attrs: buildDotnet (attrs // { type = "runtime"; });
    buildNetSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
  };

  ## Files in versions/ are generated automatically by update.sh ##
  dotnet_3_1 = import ./versions/3.1.nix buildAttrs;
  dotnet_2_1 = import ./versions/2.1.nix buildAttrs;

  runtimeIdentifierMap = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "osx-x64";
    "aarch64-darwin" = "osx-arm64";
    "x86_64-windows" = "win-x64";
    "i686-windows" = "win-x86";
  };

  # Convert a "stdenv.hostPlatform.system" to a dotnet RID
  systemToDotnetRid = system: runtimeIdentifierMap.${system} or (throw "unsupported platform ${system}");
in
{
  inherit systemToDotnetRid;

} // dotnet_3_1 // dotnet_2_1