#!/bin/sh
# pam_gnome_keyring (in /etc/pam.d/greetd) already spawned the --login
# daemon and unlocked it with the login password. --start is idempotent
# and just ensures the ssh/secrets/pkcs11 components are advertised on
# the user's actual session bus (which dbus auto-activation also handles
# lazily, but doing it explicitly avoids a first-launch race).
eval "$(gnome-keyring-daemon --start --components=ssh,secrets,pkcs11)"
export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL

# Push session env into the dbus activation environment so dbus-activated
# services inherit the right bus, display, runtime dir, and keyring sockets.
# (No --systemd: this box runs OpenRC, not systemd, so there is no systemd
# user manager to import into.)
dbus-update-activation-environment \
    DISPLAY \
    WAYLAND_DISPLAY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    DBUS_SESSION_BUS_ADDRESS \
    XDG_RUNTIME_DIR \
    SSH_AUTH_SOCK \
    GNOME_KEYRING_CONTROL
