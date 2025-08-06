{ pkgs, username, ... }: {
  programs.nh = {
    enable = true;
    flake = "/home/${username}/nix-config/";
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
    ncdu
    dig
    gh
    nmap
    tree
    neofetch
    age
    sops
  ];
}
