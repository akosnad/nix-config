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
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # we use misterio77's fork to be able to use global default for symlinking
    # impermanence.url = "github:nix-community/impermanence";
    impermanence.url = "github:misterio77/impermanence";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko/v1.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      # we use munnik's fork until https://github.com/Mic92/sops-nix/pull/637 is merged
      # this allows for setting explicit uid and gid for secret files
      # url = "github:Mic92/sops-nix";
      url = "github:munnik/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-ovmf.follows = "nixpkgs";
    };

    arion = {
      # we use our fork until https://github.com/hercules-ci/arion/pull/263 is merged
      # this allows for setting blkio_config for containers
      # url = "github:hercules-ci/arion/v0.2.1.0";
      url = "github:akosnad/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buildbot-nix.url = "github:nix-community/buildbot-nix";
  };

  outputs =
    { self
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
      forEachSystem = lib.genAttrs systems;
      pkgsForEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    in
    {
      inherit lib;

      nixosModules = import ./modules/nixos {
        inherit inputs;
      };
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };

      packages = pkgsForEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = pkgsForEachSystem (pkgs: pkgs.nixpkgs-fmt);

      devShells = pkgsForEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      checks =
        let
          machines = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) self.nixosConfigurations;
          packages = forEachSystem (system: lib.mapAttrs' (name: lib.nameValuePair "pkgs-${name}") self.packages.${system});
          checkSystem = "x86_64-linux";
          checkPkgs = pkgsFor.${checkSystem};

          codeChecks = {
            statix = checkPkgs.runCommand "statix"
              {
                nativeBuildInputs = [ checkPkgs.statix ];
              } ''
              cp ${./.}/statix.toml .
              statix check ${./.}
              touch $out
            '';
            deadnix = checkPkgs.runCommand "deadnix"
              {
                nativeBuildInputs = [ checkPkgs.deadnix ];
              } ''
              deadnix -f ${./.}
              touch $out
            '';
            fmt = checkPkgs.runCommand "fmt"
              {
                nativeBuildInputs = [ checkPkgs.nixpkgs-fmt ];
              } ''
              nixpkgs-fmt --check ${./.}
              touch $out
            '';
          };
        in
        machines // packages.${checkSystem} // codeChecks;

      nixosConfigurations = {
        athena = lib.nixosSystem {
          modules = [ ./hosts/athena ];
          specialArgs = { inherit inputs outputs; };
        };

        kratos = lib.nixosSystem {
          modules = [ ./hosts/kratos ];
          specialArgs = { inherit inputs outputs; };
        };
        zeus = lib.nixosSystem {
          modules = [ ./hosts/zeus ];
          specialArgs = { inherit inputs outputs; };
        };
        gaia = lib.nixosSystem {
          modules = [ ./hosts/gaia ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      homeConfigurations = {
        "akos@gepterem" = lib.homeManagerConfiguration {
          modules = [ ./home/akos/gepterem.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };

        "akos@athena" = lib.homeManagerConfiguration {
          modules = [ ./home/akos/athena.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };

        "akos@kratos" = lib.homeManagerConfiguration {
          modules = [ ./home/akos/kratos.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "akos@zeus" = lib.homeManagerConfiguration {
          modules = [ ./home/akos/zeus.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "akos@gaia" = lib.homeManagerConfiguration {
          modules = [ ./home/akos/gaia.nix ];
          pkgs = pkgsFor.aarch64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    };
}
