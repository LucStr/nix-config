# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    chromium = prev.chromium.overrideAttrs (oldAttrs: rec {
      commandLineArgs = [
        "--ozone-platform=wayland"
      ];
    });

    hyprland-luca = inputs.hyprland.packages.x86_64-linux.hyprland;

    hyprlock = inputs.hyprlock.packages.x86_64-linux.hyprlock;

    hyprpaper-luca = inputs.hyprpaper.packages.x86_64-linux.hyprpaper;

    rider-luca = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
      version = "2024.1.6";
      buildNumber = "241.19072.26";
      src = final.fetchurl {
        url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.1.6.tar.gz";
        sha256 = "0pmykznbzjjfqk669igvcya5zikzv5pinsx9yw00426a0rp9jcz0";
      };
      update-channel = "Rider RELEASE";
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
