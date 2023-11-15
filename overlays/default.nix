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
        (final.fetchpatch {
          url = "https://github.com/LucStr/Hyprland/commit/4afae3470198ab1c974e6182c9eec4e91c8ec881.patch";
          sha256 = "sha256-+n39IvPN9hn4r39U42dhXk793gCJytq32G7B6z/eAS0=";
        })
      ];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
