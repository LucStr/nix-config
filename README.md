# Quickinstall

1. Access remote and identify main disk `fdisk -l`.
2. Replace disk in arrow/default.nix
3. Run `nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config hosts/arrow/hardware-configuration.nix --flake .#arrow --target-host root@<ip address>` make sure to access the root user.
4. Enter disk encryption key
5. ssh into the machine. make sure firewall is configured correctly.
6. clone the repository `SSH_AUTH_SOCK=/run/user/1000/gcr/ssh git clone git@github.com:/LucStr/nix-config.git` into $HOME of user
