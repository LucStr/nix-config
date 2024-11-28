{ inputs, lib, pkgs, config, ... }: {
    nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    }; 

    # Enable OpenGL
    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
        # trying to fix `WLR_RENDERER=vulkan sway`
        vulkan-validation-layers
        # https://nixos.wiki/wiki/Accelerated_Video_Playback
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        ];
    };
}
