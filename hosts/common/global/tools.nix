{ inputs, outputs, pkgs, ... }: {
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