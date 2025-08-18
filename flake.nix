{
  description = "akosnad's NixOS configuration";

  nixConfig = {
    auto-optimise-store = true;
    builders-use-substitutes = true;
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix.fzt.one/"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix.fzt.one-1:W6+n+PqYiAINgEUYnAxoDrV0xrjPR0C0fJeIDp3nvAw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:/nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko/v1.12.0";
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
      url = "github:AshleyYakeley/NixVirt/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.flake-parts.follows = "flake-parts";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix/474d5e49962363ea69d6388dd308292a13874068";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-topology = {
      url = "github:/oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprscroller-src = {
      url = "github:akosnad/hyprscroller";
      flake = false;
    };

    iamb = {
      url = "github:ulyssa/iamb";
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

      nixosHosts' = lib.filterAttrs (n: v: v == "directory" && n != "common") (builtins.readDir "${self}/hosts");
      nixosHosts = builtins.attrNames nixosHosts';
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }:
    {
      inherit systems;
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.hercules-ci-effects.flakeModule
        inputs.nix-topology.flakeModule
        ./effects.nix
      ] ++ (builtins.attrValues (import ./modules/flake));

      perSystem = { pkgs, config, system, ... }: {
        packages = import ./pkgs { inherit pkgs inputs; };
        devShells = import ./shell.nix { inherit pkgs; } // { treefmt = config.treefmt.build.devShell; };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            rustfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            shfmt.enable = true;
            black.enable = true;
          };
        };

        topology.modules = [
          ./topology.nix
          ((import ./modules/topology.nix) outputs)
        ];

        checks =
          let
            nixosMachines = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == pkgs.system)) outputs.nixosConfigurations);
            topology = if system != "x86_64-linux" then { } else { topology = self.topology.${system}.config.output; };
          in
          nixosMachines // topology;
      };

      flake = {
        inherit lib;

        nixosModules = import ./modules/nixos { inherit lib; };
        homeManagerModules = import ./modules/home-manager;

        overlays = import ./overlays { inherit inputs outputs; };

        inherit ((lib.evalModules { modules = [{ devices = import ./devices.nix; } (import ./modules/common/devices.nix)]; }).config) devices;

        nixosConfigurations =
          let
            mkNixosConfig = host: {
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
            mkHomeConfig = { host, system, config, ... }: {
              name = "akos@${host}";
              value = lib.homeManagerConfiguration {
                modules = [
                  config
                  inputs.stylix.homeModules.stylix
                ];
                pkgs = pkgsFor.${system};
                extraSpecialArgs = { inherit inputs outputs; };
              };
            };
          in
          lib.pipe (builtins.readDir ./home/akos) [
            # all nix files in directory
            (lib.filterAttrs (filename: filetype: filetype != "directory" && (builtins.match ".+\.nix$" filename != null)))
            # <name>.nix -> <name>
            (lib.mapAttrs' (filename: _: lib.nameValuePair (lib.head (lib.match "^(.*)\.nix$" filename)) { }))
            # remove home configs that are a part of NixOS machines
            (lib.filterAttrs (host: _: !(lib.elem host nixosHosts)))
            # import files
            (lib.mapAttrs (host: _: import ./home/akos/${host}.nix))
            # generate home configs
            (lib.mapAttrs' (host: toplevel: mkHomeConfig { inherit host; inherit (toplevel) system config; }))
          ];

        esphomeConfigurations =
          let
            dir' = lib.filterAttrs (n: v: v == "regular" && n != "common.nix") (builtins.readDir "${self}/esphome-hosts");
            dir = builtins.attrNames dir';
            stripExtension = fname: lib.head (lib.splitString ".nix" fname);
            hosts = map stripExtension dir;
            applyConfig = host: (import "${self}/esphome-hosts/${host}.nix") {
              common = import "${self}/esphome-hosts/common.nix";
            };
          in
          lib.listToAttrs (map (host: lib.nameValuePair host (applyConfig host)) hosts);
      };
    });
}
