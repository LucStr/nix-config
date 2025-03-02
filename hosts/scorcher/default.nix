# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, pkgs, username, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

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
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
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
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
	  insmod fat
	  search --no-floppy --fs-uuid --set=root 0C3C-0A26
	  chainloader /efi/Microsoft/Boot/bootmgfw.efi
        }

        menuentry 'TUXEDO OS GNU/Linux' --class tuxedo --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-99d4aeb6-3ce0-4762-9428-761bce7c5140' {
	  recordfail
	  load_video
	  gfxmode $linux_gfx_mode
          insmod gzio
	  if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
	  insmod part_gpt
	  insmod ext2
	  search --no-floppy --fs-uuid --set=root 99d4aeb6-3ce0-4762-9428-761bce7c5140
	  linux	/boot/vmlinuz-6.5.0-10006-tuxedo root=UUID=99d4aeb6-3ce0-4762-9428-761bce7c5140 ro  quiet splash loglevel=3 udev.log_level=3 $vt_handoff
	  initrd	/boot/initrd.img-6.5.0-10006-tuxedo
        }
      '';
    };
  }; 

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [ "ibt=off" ];

  networking.hostName = "scorcher"; # Define your hostname.
  
  #hardware.tuxedo-rs = {
    #  enable = true;
    #tailor-gui.enable = true;
  #};
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
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
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" "ideavim" ])
    jetbrains.datagrip
    mongodb-compass-luca
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

