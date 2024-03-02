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

    hyprland-luca = inputs.hyprland.packages.x86_64-linux.hyprland;#.overrideAttrs #(oldAttrs: rec {
    #   patches = oldAttrs.patches ++ [
    #     #./hyprland-fullscreen.patch
    #   ];
    # });

    rider-luca = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
      version = "2023.3";
      buildNumber = "233.11799.303";
      src = final.fetchurl {
        url = "https://download.jetbrains.com/rider/JetBrains.Rider-2023.3.1.tar.gz";
	sha256 = "07dfbdc277d2befdb2700f515167b9bcb6464dd6d9fe59f98147c03233b6aa75";
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
