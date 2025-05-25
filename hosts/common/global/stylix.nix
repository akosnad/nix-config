{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = lib.mkDefault true;
    # FIXME: this is not used in current setup (swww) but is referenced somewhere
    image = ../../../home/akos/features/desktop/wallpapers/moon.jpg;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/classic-dark.yaml";
    fonts = {
      serif = {
        package = pkgs.recursive;
        name = "Recursive Sans Linear Static";
      };
      sansSerif = config.stylix.fonts.serif;
      monospace = {
        package = pkgs.nerd-fonts.recursive-mono;
        name = "RecMonoLinear Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        desktop = 11;
        applications = 11;
        terminal = 11;
      };
    };
    opacity = {
      terminal = 0.9;
      popups = 0.9;
    };
  };
}
