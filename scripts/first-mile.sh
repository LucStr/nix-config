#!/usr/bin/env bash
git clone https://github.com/LucStr/nix-config
rm nix-config/hosts/arrow/hardware-configuration.nix
nixos-generate-config --root /tmp/config --no-filesystems
cp /tmp/config/etc/nixos/hardware-configuration.nix nix-config/hosts/arrow/
sudo nix --extra-experimental-features "nix-command flakes" run 'github:nix-community/disko/latest#disko-install' -- --flake nix-config#arrow 
