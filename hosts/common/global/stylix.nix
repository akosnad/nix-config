{ inputs, lib, pkgs, config, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = lib.mkDefault true;
    polarity = lib.mkOverride 1200 "dark";
    base16Scheme = lib.mkOverride 1200 "${pkgs.base16-schemes}/share/themes/classic-dark.yaml";
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
        package = pkgs.noto-fonts-color-emoji;
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

  specialisation = lib.mkIf config.stylix.enable {
    light.configuration.stylix = lib.mkOverride 1100 {
      polarity = "light";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/classic-light.yaml";
    };
  };

  system.activationScripts.link-themes = {
    deps = [ "specialfs" ];
    text = /* bash */ ''
      if [ -e $systemConfig/specialisation/light ]; then
        echo linking system themes...
        rm -rf /run/theme
        mkdir -p /run/theme
        ln -sfv $systemConfig/specialisation/light /run/theme/light
        ln -sfv $systemConfig /run/theme/dark
      fi
    '';
  };
}
