{username, ...}:
{
  users.users.${username} = {
    extraGroups = [ "docker" ];
  };
  
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };

  networking.extraHosts =
    ''
      127.0.0.1 host.docker.internal
    '';
}
