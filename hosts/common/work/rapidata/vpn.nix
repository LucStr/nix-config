{username, pkgs, ...}:{
  users.users.${username}.packages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces = {
    rapidata-test = {
      autostart = true;
      address = [ "172.16.16.2/32" ];
      privateKeyFile = "/home/${username}/.wg/tinker-private";
      mtu = 1384;
      peers = [
        {
          publicKey = "IduFvdzqPWHsmzz4Qj8Ok6sUmwAsGM8yhw5d+A34ylg=";
          allowedIPs = [ "10.96.0.0/16" ];
          endpoint = "vpn.rabbitdata.ch:51820";
          persistentKeepalive = 25;
        }
      ];

      postUp = ''
        resolvectl dns rapidata-test 10.96.2.1
        resolvectl domain rapidata-test ~rabbitdata.internal
      '';

      postDown = ''
        resolvectl dns rapidata-test ""
        resolvectl domain rapidata-test ""
      '';
    };

    rapidata-prod = {
      autostart = true;
      address = [ "172.16.17.2/32" ];
      privateKeyFile = "/home/${username}/.wg/tinker-private";
      mtu = 1384;

      peers = [
        {
          publicKey = "IFmvZCNVUidd6+U/LLBzYeVHIOZQUAxWccY178H9t2A=";
          allowedIPs = [ "10.97.0.0/16" ];
          endpoint = "vpn.rapidata.ai:51820";
          persistentKeepalive = 25;
        }
      ];

      postUp = ''
        resolvectl dns rapidata-prod 10.97.2.1
        resolvectl domain rapidata-prod ~rapidata.internal jdl8d5xg4d.europe-west4.p.gcp.clickhouse.cloud
      '';

      postDown = ''
        resolvectl dns rapidata-prod ""
        resolvectl domain rapidata-prod ""
      '';
    };

    rapidata-gcp = {
      address = [ "172.16.17.2/32" ];
      privateKeyFile = "/home/${username}/.wg/tinker-private";
      autostart = false;
      mtu = 1384;

      peers = [
        {
          publicKey = "IFmvZCNVUidd6+U/LLBzYeVHIOZQUAxWccY178H9t2A=";
          allowedIPs = [ "10.97.0.0/16" "216.239.32.107/32" ];
          #allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "34.90.72.160:51820";
          persistentKeepalive = 25;
        }
      ];

      #dns = ["10.97.1.1"];

      postUp = ''
        #resolvectl dns rapidata-gcp 216.239.32.107 
        #resolvectl domain rapidata-gcp ~rapidata.ai 
        resolvectl dns rapidata-gcp 10.97.2.1
        resolvectl domain rapidata-gcp ~rapidata.internal
      '';

      postDown = ''
        resolvectl dns rapidata-gcp ""
        resolvectl domain rapidata-gcp ""
      '';
    };



    rapidata-stage = {
      autostart = false;
      address = [ "172.16.18.2/32" ];
      privateKeyFile = "/home/${username}/.wg/tinker-private";
      
      peers = [
        {
          publicKey = "mRuajHEDH0KdAK8EoRq/MUhcqOEXx5Binnhr4YDziQs=";
          allowedIPs = [ "10.98.0.0/16" ];
          endpoint = "vpn.turtledata.ch:51820";
          persistentKeepalive = 25;
        }
      ];

      postUp = ''
        resolvectl dns rapidata-stage 10.98.0.2
        resolvectl domain rapidata-stage ~internal.turtledata.ch ~eu-central-1.aws.vpce.clickhouse.cloud
      '';

      postDown = ''
        resolvectl dns rapidata-stage ""
        resolvectl domain rapidata-stage ""
      '';
    };
  };


}
