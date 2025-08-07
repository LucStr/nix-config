{username, pkgs, config, ...}:{
  users.users.${username}.packages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces = {
    rapidata-test = {
      autostart = true;
      configFile = config.sops.secrets."wg/rapidata-test.conf".path;
    };

    rapidata-prod = {
      autostart = true;
      configFile = config.sops.secrets."wg/rapidata-prod.conf".path;
    };
  };
}
