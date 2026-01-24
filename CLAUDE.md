# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix Flakes configuration repository primarily focused on **home-manager** for user environment management. It also contains NixOS system configurations for reference, but the main workflow is home-manager on non-NixOS systems (currently Gentoo).

## Common Commands

```bash
# Home-manager (primary workflow)
nh home switch                    # Switch to new home-manager config (auto-detects luca@scorcher)
nh home switch -c luca@scorcher   # Explicit config selection

# NixOS system (when on NixOS)
sudo nixos-rebuild switch --flake ~/nix-config#scorcher

# Formatting
nix fmt                           # Format all .nix files with alejandra

# Garbage collection
nh clean --keep-since 4d --keep 3
```

## Architecture

```
flake.nix
├── homeConfigurations
│   ├── luca@scorcher  → home-manager/home-gentoo.nix (Gentoo - primary)
│   ├── luca@nixos     → home-manager/home.nix (NixOS full desktop)
│   └── luca@arrow     → home-manager/home.nix
├── nixosConfigurations
│   ├── scorcher       → hosts/scorcher/ (workstation)
│   └── arrow          → hosts/arrow/ (server)
└── overlays           → stable-packages, additions, modifications
```

## Home-Manager Structure

**`home-manager/home-gentoo.nix`** - Minimal config for non-NixOS:
- Imports: `nvim/`, `tmux/`
- Manages: neovim, tmux, bash, zoxide, gh, git, nh
- Symlinks dotfiles from `config/` to `~/.config/`

**`home-manager/home.nix`** - Full NixOS desktop config:
- Additional imports: `spicetify.nix`, hyprland module
- Full desktop environment integration

**Dotfiles in `home-manager/config/`:**
- `hypr/` - Hyprland config with theme system (obsidian-glass, everforest, summer-day/night)
- `waybar/` - Status bar with matching themes
- `wofi/` - App launcher with matching themes
- `alacritty/` - Terminal config
- `scripts/` - User scripts (tvim.sh)

## Neovim Configuration

Located in `home-manager/nvim/`:
- `default.nix` - Plugin declarations and package dependencies
- `plugins/*.lua` - Plugin configurations (lsp, treesitter, telescope, etc.)
- `options.lua` - Vim options
- `keybinds/default.lua` - Key mappings

Uses nvim 0.11+ APIs (`vim.lsp.config`, `vim.treesitter.start`).

## Key Patterns

**Symlinked dotfiles** - Configs are symlinked (not copied) so edits in `~/.config/` reflect in the repo:
```nix
home.file = let
  mkSymlink = name: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nix-config/home-manager/config/${name}";
in ...
```

**Overlays** - Three overlays applied to all configs:
- `stable-packages` - nixpkgs-stable as `pkgs.stable`
- `additions` - Custom packages from `pkgs/`
- `modifications` - Package overrides (chromium wayland, rider version)

**Theme coordination** - Hyprland, Waybar, and Wofi share theme definitions in their respective `colors/` directories.

## Hosts (NixOS)

Modular structure in `hosts/common/`:
- `global/` - Base config (nix settings, networking, tools)
- `gpu/nvidia-laptop/`, `gpu/intel-laptop/` - GPU drivers
- `hyprland/` - Desktop compositor
- `development/` - Dev tools (.dotnet, .vscode, .javascript, .infra)
- `gaming/`, `virtualization/`, `work/rapidata/`

## Secrets

Uses sops-nix with age encryption. Secrets in `secrets/secrets.yaml`.
