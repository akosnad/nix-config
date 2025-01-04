{
  description = "akosnad's NixOS configuration";

  nixConfig = {
    auto-optimise-store = true;
    builders-use-substitutes = true;
    extra-substituters = [
      "https://akosnad.cachix.org"
      "https://akosnad-hci.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "akosnad.cachix.org-1:mohKqHWc/aZqkAOWmPfvqRiHmhQ3wQ6R7g9ULwNaRfw="
      "akosnad-hci.cachix.org-1:JDYKY8LpJEn0s1jUcUEcLFTAOFl5WF4zArxAZL2UqVw="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix.fzt.one-1:W6+n+PqYiAINgEUYnAxoDrV0xrjPR0C0fJeIDp3nvAw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # we use misterio77's fork to be able to use global default for symlinking
    # impermanence.url = "github:nix-community/impermanence";
    impermanence.url = "github:misterio77/impermanence";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko/v1.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-ovmf.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
  };

  outputs =
    { self
    , flake-parts
    , nixpkgs
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      nixosHosts = [
        { host = "athena"; }
        { host = "kratos"; }
        { host = "zeus"; }
        { host = "gaia"; arch = "aarch64-linux"; }
        { host = "ocean"; }
      ];
      homes = nixosHosts ++ [{ host = "gepterem"; }];
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }:
    {
      inherit systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { pkgs, config, ... }: {
        packages = import ./pkgs { inherit pkgs; };
        devShells = import ./shell.nix { inherit pkgs; } // { treefmt = config.treefmt.build.devShell; };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            rustfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
          };
        };

        checks =
          let
            nixosMachines = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == pkgs.system)) outputs.nixosConfigurations);
          in
          nixosMachines;
      };

      flake = {
        inherit lib;

        nixosModules = import ./modules/nixos {
          inherit inputs;
        };
        homeManagerModules = import ./modules/home-manager;

        overlays = import ./overlays { inherit inputs outputs; };

        nixosConfigurations =
          let
            mkNixosConfig = { host, ... }: {
              name = host;
              value = lib.nixosSystem {
                modules = [ ./hosts/${host} ];
                specialArgs = { inherit inputs outputs; };
              };
            };
          in
          builtins.listToAttrs (lib.map mkNixosConfig nixosHosts);

        homeConfigurations =
          let
            mkHomeConfig = { host, arch ? "x86_64-linux", ... }: {
              name = "akos@${host}";
              value = lib.homeManagerConfiguration {
                modules = [ ./home/akos/${host}.nix ];
                pkgs = pkgsFor.${arch};
                extraSpecialArgs = { inherit inputs outputs; };
              };
            };
          in
          builtins.listToAttrs (lib.map mkHomeConfig homes);
      };
    });
}
