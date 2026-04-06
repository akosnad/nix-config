{ inputs, ... }:
{
  config.flake.modules.homeManager.shell = { pkgs, ... }: {
    imports = [
      inputs.nix-index-database.homeModules.nix-index
    ];

    home.packages = with pkgs; [
      comma
    ];
  };
}
