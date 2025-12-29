{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  home.packages = with pkgs; [
    comma
  ];
}
