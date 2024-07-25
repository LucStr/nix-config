{
  description = "Luca's nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    #tuxedo-nixos = {
    #  url = "github:blitz/tuxedo-nixos";
    #};
    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?rev=918d8340afd652b011b937d29d5eea0be08467f5&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:the-argus/spicetify-nix";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    spicetify-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      scorcher = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/scorcher
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "luca@scorcher" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs spicetify-nix; };
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
          ./home-manager/spicetify.nix
        ];
      };
    };
  };
}
