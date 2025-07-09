# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, pkgs, username, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      #(import ../common/disko/simple-encrypted.nix {inherit lib; disk = "/dev/nvme1n1";})

      ../common/global
      ../common/bluetooth
      ../common/gpu/nvidia-laptop
      ../common/hyprland
      ../common/workstation
      ../common/work/rapidata
      ../common/virtualization
      ../common/development
      ../common/gaming
    ];

  nixpkgs = {
    # You can add overlays here
    overlays = builtins.attrValues outputs.overlays;
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  # nix.nixPath = ["/etc/nix/path"];
  #environment.etc =
  #  lib.mapAttrsdev'
  #  (name: value: {
  #    name = "nix/path/${name}";
  #    value.source = value.flake;
  #  })
  #  config.nix.registry;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
  }; 
  boot.loader.grub.enable = false; # Disable GRUB, use systemd-boot instead.
  boot.loader.systemd-boot.enable = lib.mkForce false; # Enable systemd-boot.
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [ "ibt=off" ];

  networking.hostName = "scorcher"; # Define your hostname.
  
  #hardware.tuxedo-rs = {
    #  enable = true;
    #tailor-gui.enable = true;
  #};

  services = {
    udev.packages = with pkgs; [ 
        ledger-udev-rules
        # potentially even more if you need them
    ];
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username}.packages = with pkgs; [
    mongodb-compass
    jb
    mariadb
    nodejs_20
    nodePackages.typescript
    redis
    mongosh
    python311
    gdb
    filezilla
    glib
    mongosync
    mongodb-tools
    ledger-live-desktop
    pipenv
    logisim-evolution
    gcc
    ripgrep
    yarn
    jmeter
    mkcert
    dotnet-depends
    cargo
    rustc
    grpc-tools
    ffmpeg
    uv
  ];

  security.pki.certificateFiles = [ /home/${username}/.local/share/mkcert/rootCA.pem ];

  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      environment.sessionVariables = {
        WLR_DRM_DEVICES  = "/dev/dri/card0";
        KWIN_DRM_DEVICES  = "/dev/dri/card0";
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

