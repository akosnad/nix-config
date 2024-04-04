{ lib, inputs, ... }: let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
    ./features/desktop/hyprland
  ];

  programs.firefox = {
    enable = true;
  };

  colorscheme = lib.mkDefault colorSchemes.horizon-dark;
}
