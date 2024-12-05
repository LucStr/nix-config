{pkgs, username, ...}:
let
  dotnet-combined = (with pkgs; dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_8_0
      dotnetCorePackages.sdk_9_0
  ]);
in
{
  users.users.${username}.packages = with pkgs; [
    dotnet-combined
    (jetbrains.plugins.addPlugins (jetbrains.rider.overrideAttrs (attrs: {
    postInstall = (attrs.postInstall or "") + lib.optionalString (stdenv.hostPlatform.isLinux) ''
      (
        cd $out/rider

        ls -d $PWD/plugins/cidr-debugger-plugin/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
        xargs patchelf \
          --replace-needed libssl.so.10 libssl.so \
          --replace-needed libcrypto.so.10 libcrypto.so \
          --replace-needed libcrypt.so.1 libcrypt.so

        for dir in lib/ReSharperHost/linux-*; do
          rm -rf $dir/dotnet
          ln -s ${dotnet-sdk_7.unwrapped}/share/dotnet $dir/dotnet 
        done
      )
    '';
    })) [ "github-copilot" "ideavim" ])
    jb
    
  ];
}
