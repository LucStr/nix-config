# This file (and the global directory) holds config that I use on all hosts
{ username, inputs, outputs, pkgs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.home-manager.nixosModules.home-manager
    ./tools.nix
    ./nix.nix
    ./sops.nix
    ../certificates
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  services.automatic-timezoned.enable = true;
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate"; # can be remove once https://github.com/NixOS/nixpkgs/pull/391845 is merged

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.resolved = {
    enable = true;
    llmnr = "false";
    extraConfig = ''
      MulticastDNS=no
    '';
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    dispatcherScripts = [{
      type = "basic";
      source = pkgs.writeText "enable-mdns-physical" ''
        # Enable mDNS on physical network interfaces (WiFi and Ethernet)
        case "$DEVICE_IFACE" in
          wlo1|enp58s0|enp*)
            if [ "$2" = "up" ]; then
              ${pkgs.systemd}/bin/resolvectl mdns "$DEVICE_IFACE" yes
            fi
            ;;
        esac
      '';
    }];
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "rapidnet" ];
  };
}
