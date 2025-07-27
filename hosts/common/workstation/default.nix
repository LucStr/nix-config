{username, pkgs, ...}:
{
  users.users.${username}.packages = with pkgs; [
    (chromium.override {
        enableWideVine = true;
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--enable-native-notifications"
        ];
        #proprietaryCodecs = true;
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

  services.pulseaudio.enable = false;
  services.pulseaudio.support32Bit = true;
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
