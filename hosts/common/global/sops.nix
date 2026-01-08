# This file (and the global directory) holds config that I use on all hosts
{ username, inputs, outputs, config, ... }:
let
    isEd25519 = k: k.type == "ed25519";
    keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
    getPath = k: k.path;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ../../../secrets/secrets.yaml;

  sops.age.sshKeyPaths = map getPath keys;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  sops.secrets = {
    "development_root_ca" = {
      owner = username;
      group = "users";
      mode = "0440";
    };
    "development_root_ca_key" = {
      owner = username;
      group = "users";
      mode = "0440";
    };
    "trusted_certificates" = {
      owner = username;
      group = "users";
      mode = "0440";
    };
    "wg/rapidata-test.conf" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
    "wg/rapidata-prod.conf" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
    "wg/home.conf" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
