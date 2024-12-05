{username, ...}:
{
  users.users.${username} = {
    extraGroups = [ "docker" ];
  };
  
  virtualisation.docker.enable = true;
  networking.extraHosts =
    ''
      127.0.0.1 host.docker.internal
    '';
}
