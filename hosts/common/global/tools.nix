{ pkgs, ... }: {
  programs.nh = {
    enable = true;
    flake = "/home/luca/nix-config/";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    killall
    home-manager
    zip
    unzip
  ];
}
