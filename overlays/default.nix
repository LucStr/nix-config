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

    hyprland-luca = prev.hyprland.overrideAttrs (oldAttrs: rec {
      patches = oldAttrs.patches ++ [
        ./hyprland-fullscreen.patch
      ];
    });

    rider-luca = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
      version = "2023.3 RC";
      buildNumber = "233.11799";
      src = final.fetchurl {
        url = "https://download.jetbrains.com/rider/JetBrains.Rider-2023.3-RC1-233.11799.183.tar.gz";
	sha256 = "66945b54fd5496be0e7789147d4967d7cd578b2685ad65808dee204ba5d6cf95";
      };
      update-channel = "RD-EAP-licensing-RELEASE";
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
