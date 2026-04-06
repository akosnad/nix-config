{ config, lib, ... }:
{
  options.stylix.targets.oh-my-posh.enable =
    config.lib.stylix.mkEnableTarget "Oh My Posh" true;

  config =
    lib.mkIf (config.stylix.enable && config.stylix.targets.oh-my-posh.enable)
      {
        programs.oh-my-posh.settings = {
          palette = with config.lib.stylix.colors.withHashtag; {
            bg = base02;
            fg = base06;
            fg_faded = base05;
            info_bg = base0D;
            info_fg = base00;
            warning_bg = base0A;
            warning_fg = base00;
            error_bg = base08;
            error_fg = base00;
          };
        };
      };
}
