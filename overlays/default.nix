# This file defines overlays
{inputs, lib, ...}: 
let 

  plugins = inputs.nix-jetbrains-plugins.plugins."${builtins.currentSystem}";
  ideWithPlugins = jetbrains: ide-name: plugin-ids:
    let 
      ide = jetbrains."${ide-name}";
      processPlugin = 
        plugin:
        if lib.isDerivation plugin then
          plugin
        else if jetbrains.plugins.raw.byId ? "${plugin}" || jetbrains.plugins.raw.byName ? "${plugin}" then
          plugin
        else if plugins."${ide-name}"."${ide.version}" ? "${plugin}" then
          plugins."${ide-name}"."${ide.version}"."${plugin}"
        else
          throw "Could not resolve plugin ${plugin}";

      mappedPlugins = map processPlugin plugin-ids;
    in 
      jetbrains.plugins.addPlugins ide mappedPlugins;

in {
  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

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

    jetbrains.rider = 
      let 
        stableRider = prev.stable.jetbrains.rider;
        copilot = prev.stable.jetbrains.plugins.raw.byName."github-copilot" stableRider.pname stableRider.buildNumber;
      in
        ideWithPlugins prev.stable.jetbrains "rider" [
          copilot
          "com.intellij.csharpier"
        ];

    mongodb-compass = (prev.mongodb-compass.overrideAttrs (old: {
      buildCommand = old.buildCommand + ''
        sed -i 's|^Exec=mongodb-compass %U$|Exec=mongodb-compass --password-store="gnome-libsecret" --ignore-additional-command-line-flags %U|' $out/share/applications/mongodb-compass.desktop
      '';
    }));

    rider-luca = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
      version = "2024.3.3";
      buildNumber = "243.22562.250";
      src = final.fetchurl {
        url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.3.3.tar.gz";
        sha256 = "01r8ir6zv45idhmskdrjd40fzb4qjrgkzkjyikqnph451mn8519i";
      };
      update-channel = "Rider RELEASE";
    });
    #rider-luca = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
    #  version = "2024.2.5";
    #  buildNumber = "242.22855.90";
    #  src = final.fetchurl {
    #    url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.2.5.tar.gz";
    #    sha256 = "1zlxkynznd1zcx3s0bs3vz3vn36b0aia0z9bpx7339phb723z2vw";
    #  };
    #  update-channel = "Rider RELEASE";
    #});
  };

}
