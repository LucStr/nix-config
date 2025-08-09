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
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  networking.firewall.trustedInterfaces = [ "virbr0" ];


  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
      virtiofsd
  ];
}
