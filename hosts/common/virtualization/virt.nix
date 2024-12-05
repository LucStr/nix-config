{pkgs, username, ...}:
{
  users.users.${username} = {
    extraGroups = [ "libvirtd" "vboxusers" ];
  
  };
  virtualisation.virtualbox.host.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
      virtiofsd
  ];
}
