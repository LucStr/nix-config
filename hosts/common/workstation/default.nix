{username, pkgs, ...}:
{
  users.users.${username}.packages = with pkgs; [
    (chromium.override {
        enableWideVine = true;
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--enable-native-notifications"
        ];
      })
    discord
    spotify
    libreoffice-qt
    signal-desktop
    zoom-us
    vlc
    libvlc
    playerctl
  ];

  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pulsemixer
  ];
}
