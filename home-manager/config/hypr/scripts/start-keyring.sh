#!/bin/sh

# Only start if not already running
if ! pgrep -u "$USER" gnome-keyring-daemon >/dev/null 2>&1; then
  eval "$(gnome-keyring-daemon --start --components=ssh,secrets,pkcs11)"
  export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL
fi
