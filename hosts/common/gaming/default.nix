{username, pkgs, ...}:
{
  users.users.${username}.packages = with pkgs; [
    lutris
    prismlauncher
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
  };


}
