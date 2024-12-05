{...}:{
  imports = [
    ./vpn.nix
  ];

  networking.extraHosts =
    ''
      127.0.0.1 rapids.rapidata.dev
      127.0.0.1 app.rapidata.dev
      127.0.0.1 api.rapidata.dev
      127.0.0.1 auth.rapidata.dev
    '';

  networking.firewall.trustedInterfaces = [ "rapidnet" ];
}
