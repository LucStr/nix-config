# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, outputs, lib, config, username, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      (import ../common/disko/simple-encrypted.nix {inherit lib; inherit config; disk = "/dev/vda";})

      ../common/global
      #../common/bluetooth
      ../common/gpu/intel-laptop
      ../common/hyprland
      #../common/workstation
      #../common/work/rapidata
      #../common/virtualization
      #../common/development
      #../common/gaming
    ];
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
      config = {
      allowUnfree = true;
    };
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      useOSProber = true;
    };
  }; 

  # Allow ssh access to the root user
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMp0YrTtvwkL1jo1KIJTbd+Vwll3kXcQDX4PrW/thzhX"
  ];
  networking.firewall.allowedTCPPorts = [ 22 ];

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [ "ibt=off" ];

  networking.hostName = "arrow";

  users.users.${username} = {
    packages = with pkgs; [
      teamspeak_client
      ghidra
      remmina
      reglookup
    ];
    hashedPassword = "$y$j9T$sc1SO8yRKMAwkjdaQohD..$v2efnAKJ.l8u5OelI1mwTa1qVlrJ8nU4cOadCzPyqPC"; # Peter1234 (hashed via nix shell nixpkgs#whois -c mkpasswd -m yescrypt), make sure to change
  };

  system.stateVersion = "25.05";
}

