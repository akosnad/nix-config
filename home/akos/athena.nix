{ lib, inputs, ... }: let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/desktop/hyprland
  ];

  colorscheme = lib.mkDefault colorSchemes.horizon-dark;
}
