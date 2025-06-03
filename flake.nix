{
  description = "NixOS + WSL + LazyVim configuration";

  inputs = {
    # Stable NixOS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Unstable channel for bleeding-edge packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (matching stable)
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR: community package overlays
    nur.url = "github:nix-community/NUR";

    # WSL support
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Command-not-found database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    with inputs;
    let
      # REMOVED: secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays =
        system:
        import nixpkgs rec {
          inherit system;

          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              # Add any insecure packages here if needed
            ];
          };

          overlays = [
            nur.overlays.default
            (_final: prev: {
              unstable = import nixpkgs-unstable {
                inherit (prev) system;
                inherit config;
              };
            })
          ];
        };

      configurationDefaults = args: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit inputs self; # REMOVED: 'secrets' from inherit
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          hostname,
          username,
          args ? { },
          modules,
        }:
        let
          specialArgs = argDefaults // { inherit hostname username; } // args;
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          pkgs = nixpkgsWithOverlays system;
          modules = [
            (configurationDefaults specialArgs)
            home-manager.nixosModules.home-manager
          ] ++ modules;
        };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

      nixosConfigurations.nixos = mkNixosConfiguration {
        hostname = "nixos";
        username = "botirk";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./wsl.nix
        ];
      };

    };
}
