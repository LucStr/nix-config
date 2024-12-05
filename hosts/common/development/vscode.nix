{inputs, pkgs, username, ...}:
{
  users.users.${username}.packages = with pkgs; [
    (vscode-with-extensions.override
    {
      #vscode = pkgs.vscodium;
      vscodeExtensions  =[
        # C# Development
        ms-dotnettools-csdevkit
        ms-dotnettools-csharp
      ] ++ (with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
        ms-python.python
        ms-python.vscode-pylance
        sainnhe.everforest
        bbenoist.nix
        xdebug.php-debug
        bmewburn.vscode-intelephense-client
        ms-vscode-remote.remote-containers
        ms-dotnettools.vscode-dotnet-runtime
        esbenp.prettier-vscode
        github.copilot
        redhat.vscode-yaml
        ms-kubernetes-tools.vscode-kubernetes-tools
      ]);
    })
  ];
}
