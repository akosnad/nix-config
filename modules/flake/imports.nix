{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.treefmt-nix.flakeModule
    inputs.hercules-ci-effects.flakeModule
    inputs.nix-topology.flakeModule
  ];

  config.flake.modules.nixos.base = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.nixos-wsl.nixosModules.default
      inputs.nix-topology.nixosModules.default
      inputs.niri-flake.nixosModules.niri
      inputs.stylix.nixosModules.stylix
      inputs.impermanence.nixosModules.impermanence
      inputs.disko.nixosModules.disko
    ];
  };

  config.flake.modules.homeManager.base = {
    imports = [
      inputs.spicetify.homeManagerModules.spicetify
      inputs.vscode-server.homeModules.default
    ];
  };
}
