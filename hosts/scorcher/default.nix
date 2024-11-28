# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, pkgs, ... }:

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

  dotnet-combined = (with pkgs.stable.dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_9_0
  ]);
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../common/global
      ../common/bluetooth
      ../common/gpu/nvidia-laptop
      #../common/sshd
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
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.extraHosts =
    ''
      127.0.0.1 host.docker.internal
      127.0.0.1 rapids.rapidata.dev
      127.0.0.1 app.rapidata.dev
      127.0.0.1 api.rapidata.dev
      127.0.0.1 auth.rapidata.dev
      10.97.5.2 kubernetes.default.svc.rapidata.prod
    '';
  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.resolved = {
    enable = true;
    
      #    extraConfig = ''
      #DNS=216.239.32.107 216.239.34.107 216.239.36.107 216.239.38.107
      #Domains=rapidata.ai
    #    '';
  };
  networking.wg-quick.interfaces = {
    rapidata-test = {
      autostart = true;
      address = [ "172.16.16.2/32" ];
      privateKeyFile = "/home/luca/.wg/tinker-private";
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
      privateKeyFile = "/home/luca/.wg/tinker-private";
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
      privateKeyFile = "/home/luca/.wg/tinker-private";
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
      privateKeyFile = "/home/luca/.wg/tinker-private";
      
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
  users.users.luca = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "adbusers" "libvirtd"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      (chromium.override {
        enableWideVine = true;
        commandLineArgs = [
          "--ozone-platform-hint=auto"
	        "--enable-native-notifications"
        ];
      })
      tree
      alacritty
      wofi
      nemo
      gvfs
      spotify
      hyprpaper-luca
      hyprlock
      jq
      dotnet-combined
      (jetbrains.plugins.addPlugins (jetbrains.rider.overrideAttrs (attrs: {
      postInstall = (attrs.postInstall or "") + lib.optionalString (stdenv.hostPlatform.isLinux) ''
        (
          cd $out/rider

          ls -d $PWD/plugins/cidr-debugger-plugin/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
          xargs patchelf \
            --replace-needed libssl.so.10 libssl.so \
            --replace-needed libcrypto.so.10 libcrypto.so \
            --replace-needed libcrypt.so.1 libcrypt.so

          for dir in lib/ReSharperHost/linux-*; do
            rm -rf $dir/dotnet
            ln -s ${dotnet-sdk_7.unwrapped}/share/dotnet $dir/dotnet 
          done
        )
      '';
    })) [ "github-copilot" "ideavim" ])
      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" "ideavim" ])
      jetbrains.datagrip
      mongodb-compass-luca
      jb
      discord
      pulsemixer
      mariadb
      #bruno
      nodejs_20
      corepack_20
      nodePackages.typescript
      stable.awscli2
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      wl-clipboard
      cliphist
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
      mongodb-tools
      (vscode-with-extensions.override
        {
          #vscode = pkgs.vscodium;
          vscodeExtensions  =[
            # C# Development
            ms-dotnettools-csdevkit
            ms-dotnettools-csharp
          ] ++ (with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
            ms-python.python
            ms-python.vscode-pylance
            sainnhe.everforest
            bbenoist.nix
            xdebug.php-debug
            bmewburn.vscode-intelephense-client
	          ms-vscode-remote.remote-containers
            ms-dotnettools.vscode-dotnet-runtime
            esbenp.prettier-vscode
            github.copilot
            redhat.vscode-yaml
            ms-kubernetes-tools.vscode-kubernetes-tools
          ]);
        }
      )
      prismlauncher
      dig
      playerctl
      swaynotificationcenter
      gitkraken
      s3fs
      gcsfuse
      libreoffice-qt
      ncdu
      ledger-live-desktop
      pipenv
      logisim-evolution
      vlc
      libvlc
      signal-desktop
      gcc
      ripgrep
      yarn
      jmeter
      kubectl
      kubernetes-helm
      argocd
      mkcert
      kustomize
      dotnet-depends
    ];
  };

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
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  #programs.sway.enable = true;

  programs.waybar.enable = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  # virt-manager
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
      swtpm.enable = true;
    };
  };

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
      virtiofsd
  ];
  programs.virt-manager.enable = true;
  programs.seahorse.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
  };

  programs.nh = {
    enable = true;
    flake = "/home/luca/nix-config/";
  };

  # Install KDE
  #services.xserver.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "luca";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  #services.xserver.windowManager.qtile.enable = true
  #services.xserver.desktopManager.plasma5.enable = true;

  security.pki.certificateFiles = [ /home/luca/.local/share/mkcert/rootCA.pem ];

  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      environment.sessionVariables = {
        WLR_DRM_DEVICES  = "/dev/dri/card0";
        KWIN_DRM_DEVICES  = "/dev/dri/card0";
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
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "rapidnet" ];
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

