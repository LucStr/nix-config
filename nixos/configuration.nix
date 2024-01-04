# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, config, pkgs, lib,... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  #  lib.mapAttrs'
  #  (name: value: {
  #    name = "nix/path/${name}";
  #    value.source = value.flake;
  #  })
  #  config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

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
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.wg-quick.interfaces = {
    rapidata-test = {
      address = [ "172.16.16.2/32" ];
      privateKeyFile = "/home/luca/.wg/tinker-private";
      
      peers = [
        {
          publicKey = "IduFvdzqPWHsmzz4Qj8Ok6sUmwAsGM8yhw5d+A34ylg=";
          allowedIPs = [ "10.96.0.0/16" ];
          endpoint = "vpn.rabbitdata.ch:51820";
          persistentKeepalive = 25;
        }
      ];
    };
    rapidata-prod = {
      address = [ "172.16.17.2/32" ];
      privateKeyFile = "/home/luca/.wg/tinker-private";
      
      peers = [
        {
          publicKey = "IduFvdzqPWHsmzz4Qj8Ok6sUmwAsGM8yhw5d+A34ylg=";
          allowedIPs = [ "10.97.0.0/16" ];
          endpoint = "vpn.turtledata.ch:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  
  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "adbusers"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      (chromium.override {
        commandLineArgs = [
          "--ozone-platform-hint=auto"
	  "--enable-native-notifications"
        ];
      })
      tree
      alacritty
      wofi
      cinnamon.nemo
      spotify
      hyprpaper
      jq
      (with dotnetCorePackages; combinePackages [
        sdk_6_0
        sdk_7_0
	sdk_8_0
      ])
      (jetbrains.plugins.addPlugins rider-luca [ "github-copilot" "ideavim" ])
      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" "ideavim" ])
      jetbrains.datagrip
      mongodb-compass-luca
      jb
      discord
      pulsemixer
      mariadb
      bruno
      nodejs_20
      awscli2
      google-cloud-sdk
      wl-clipboard
      wireguard-tools
      terraform
      redis
      vulkan-tools
      lutris
      wlr-randr
      mongosh
      xdg-utils
      zoom-us
      python311
      grim
      slurp
      act
      gdb
      filezilla
      gh
      brightnessctl
      neofetch
      goldy-plasma-theme
      glib
      configure-gtk
      dbus-sway-environment
      everforest-theme
      mongosync
      (pkgs.vscode-with-extensions.override
        {
          #vscode = pkgs.vscodium;
          vscodeExtensions = with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
            ms-python.python
            ms-python.vscode-pylance
            sainnhe.everforest
            bbenoist.nix
            xdebug.php-debug
            bmewburn.vscode-intelephense-client
          ];
        }
      )
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    htop
    killall
    home-manager
    xorg.xlsclients
    zip
    unzip
    swaynotificationcenter
  ];

  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland-luca;
  };

  programs.sway.enable = true;

  programs.waybar.enable = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  
  # Make audio buttons on bluetooth devices work 
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
};

 
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  }; 

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      # trying to fix `WLR_RENDERER=vulkan sway`
      vulkan-validation-layers 
      # https://nixos.wiki/wiki/Accelerated_Video_Playback
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

environment.variables.VDPAU_DRIVER = "va_gl";
environment.variables.LIBVA_DRIVER_NAME = "nvidia";
 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Install KDE
  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.windowManager.qtile.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      #reverseSync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    }; 
  };

  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
      };
    };
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

