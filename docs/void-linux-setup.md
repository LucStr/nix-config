# Void Linux Setup for Hyprland via Home Manager

This guide documents all manual steps required to set up Void Linux on scorcher with Hyprland managed by Home Manager.

## Prerequisites

- Fresh Void Linux installation (glibc version recommended)
- Internet connection
- Root access

---

## 1. System Packages (as root)

Install required system packages that cannot be managed by Nix:

```bash
# Update system
xbps-install -Su

# Display manager and session infrastructure
xbps-install -S sddm dbus elogind polkit

# NVIDIA GPU drivers (for scorcher)
xbps-install -S nvidia nvidia-libs nvidia-libs-32bit
# For hybrid graphics (Intel + NVIDIA laptop)
xbps-install -S nvidia-prime

# GNOME Keyring (for secrets/credentials)
xbps-install -S gnome-keyring libsecret

# gvfs for Nemo file manager features (trash, network mounts, MTP)
xbps-install -S gvfs gvfs-mtp gvfs-smb

# XDG portal base packages (Home Manager provides hyprland portal)
xbps-install -S xdg-desktop-portal xdg-desktop-portal-gtk

# Audio (PipeWire)
xbps-install -S pipewire wireplumber alsa-pipewire

# Basic utilities
xbps-install -S curl git bash
```

---

## 2. Enable System Services (as root)

Void Linux uses runit instead of systemd. Enable required services:

```bash
# D-Bus (required for most desktop functionality)
ln -s /etc/sv/dbus /var/service/

# elogind (session management, replaces systemd-logind)
ln -s /etc/sv/elogind /var/service/

# SDDM display manager
ln -s /etc/sv/sddm /var/service/

# PipeWire (audio) - runs as user service, but needs D-Bus
# PipeWire will be started via exec-once in hyprland.conf
```

---

## 3. Install Nix Package Manager (as regular user)

Install Nix in multi-user mode:

```bash
# Download and run the official installer
sh <(curl -L https://nixos.org/nix/install) --daemon

# After installation, start a new shell or source the profile
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Verify installation:

```bash
nix --version
```

### Enable Flakes

Create or edit `~/.config/nix/nix.conf`:

```bash
mkdir -p ~/.config/nix
cat >> ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF
```

---

## 4. Install Home Manager (as regular user)

```bash
# Add the Home Manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Install Home Manager
nix-shell '<home-manager>' -A install
```

Verify installation:

```bash
home-manager --version
```

---

## 5. Clone the nix-config Repository

```bash
# Clone to home directory
git clone https://github.com/LucStr/nix-config.git ~/nix-config

# Or if already exists elsewhere, ensure it's at ~/nix-config
```

---

## 6. Deploy Home Manager Configuration

```bash
cd ~/nix-config

# Build and activate the Void Linux configuration
home-manager switch --flake .#luca@void

# Rebuild font cache after first activation
fc-cache -fv
```

---

## 7. Create Hyprland Session File (as root)

SDDM needs a desktop entry to show Hyprland as a login option:

```bash
cat > /usr/share/wayland-sessions/hyprland-nix.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland (Nix)
Comment=Hyprland compositor via Home Manager
Exec=/home/luca/.local/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
EOF
```

---

## 8. Configure PAM for GNOME Keyring (as root)

Edit `/etc/pam.d/sddm` to auto-unlock GNOME Keyring on login:

```bash
# Add these lines to /etc/pam.d/sddm

# At the end of the 'auth' section:
auth       optional     pam_gnome_keyring.so

# At the end of the 'session' section:
session    optional     pam_gnome_keyring.so auto_start
```

Example complete `/etc/pam.d/sddm`:

```
auth       include      system-login
auth       optional     pam_gnome_keyring.so

account    include      system-login

password   include      system-login

session    include      system-login
session    optional     pam_gnome_keyring.so auto_start
```

---

## 9. Configure PipeWire (as regular user)

PipeWire needs to run as a user service. Add to your Hyprland config (`~/.config/hypr/hyprland.conf`) in the `exec-once` section:

```bash
# These should already be in your hyprland.conf exec-once section
exec-once = pipewire
exec-once = pipewire-pulse
exec-once = wireplumber
```

If not present, add them.

---

## 10. Reboot and Login

```bash
# Reboot the system
sudo reboot
```

After reboot:
1. SDDM should appear
2. Select "Hyprland (Nix)" from the session dropdown
3. Login with your password

---

## Troubleshooting

### Hyprland doesn't appear in SDDM

- Check the desktop file exists: `ls -la /usr/share/wayland-sessions/`
- Check the start script exists: `ls -la ~/.local/bin/start-hyprland`
- Verify permissions: `chmod +x ~/.local/bin/start-hyprland`

### Black screen after login

- Switch to TTY (Ctrl+Alt+F2)
- Check Hyprland logs: `cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log`
- Verify NVIDIA drivers: `nvidia-smi`

### No audio

- Check PipeWire is running: `pgrep -a pipewire`
- Restart PipeWire: `pkill pipewire; pipewire &`
- Check WirePlumber: `wpctl status`

### GTK apps look wrong

- Run: `~/.nix-profile/bin/configure-gtk`
- Or manually: `gsettings set org.gnome.desktop.interface gtk-theme 'Everforest-Dark-BL'`

### Nix commands not found after reboot

Add to `~/.bashrc` or `~/.bash_profile`:

```bash
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
```

### Home Manager commands not found

```bash
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
```

### Screen tearing / flickering on NVIDIA

The environment variables in `home-void.nix` should handle this. If issues persist, try adding to hyprland.conf:

```
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_DRM_NO_ATOMIC,1
```

---

## Updating

### Update Home Manager configuration

```bash
cd ~/nix-config
git pull
home-manager switch --flake .#luca@void
```

### Update Nix flake inputs

```bash
cd ~/nix-config
nix flake update
home-manager switch --flake .#luca@void
```

### Update Void Linux system packages

```bash
sudo xbps-install -Su
```

---

## Directory Structure Reference

After setup, relevant paths:

```
~/.nix-profile/           # Nix profile (symlinks to installed packages)
~/.local/bin/start-hyprland  # Hyprland session launcher
~/.local/share/fonts/     # Nix-managed fonts
~/.config/hypr/           # Hyprland config (symlinked from nix-config)
~/.config/waybar/         # Waybar config (symlinked from nix-config)
~/.config/wofi/           # Wofi config (symlinked from nix-config)
~/nix-config/             # The nix-config repository
```
