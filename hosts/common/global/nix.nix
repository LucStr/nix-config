{ inputs, lib, pkgs, ... }:
{
  nix = {
    settings = {
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
    };

    gc = {
        automatic = true;
        dates = "weekly";
        # Keep the last 5 generations
        options = "--delete-older-than +5";
    };
  };
}