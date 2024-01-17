{ inputs, lib, pkgs, config, ... }: {
  services.openssh.enable = true;
  users.users.jorge = {
    isNormalUser = true;  
    extraGroups = [ ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvrlOREJVy63bgJlnXCavhB5TPS3e9VxoMHJHquGDblfUJlcKrJrNrxQ/CJSsSiL7hGtofSie+gpP04ta2RPH33NMIKVZSuaDkzzjKkOt8jhIWuxmmBwOLoUj/OKsVbZEMtxWdTjQwY98SQ1vNakWcj1NR+zkAYpi3q2KJEMiuuNI7r19AzaCRF7cuC8qaZpgJq6c7pHhGE6SRoMXflg2c0G+wPCwbdp17hTJWEpRtcPY63jTg3b9X01l+gtrjSPaL0n74hcgMuS8A5hVoLHFEZ6epBcurVuPQpAxP6C2sqfZ/n9iL404HTU1b44f9OPiUjs61vjfAM6cNbLRC18IX jorge" # content of authorized_keys file
    # note: ssh-copy-id will add user@your-machine after the public key
    # but we can remove the "@your-machine" part
    ];
  };
}