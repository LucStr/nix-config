{pkgs, username, ...}:
{
  users.users.${username}.packages = with pkgs; [
      nodejs_20
      nodePackages.typescript
      yarn
  ];
}
