{ pkgs, username, ... }:{
  services = {
    udev.packages = with pkgs; [ 
      ledger-udev-rules
    ];
  };

  users.users.${username} = {
    packages = with pkgs; [
      ledger-live-desktop
    ];
  };
}
