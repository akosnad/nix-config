{ inputs, lib, config, pkgs, ... }:
let
  name = "glide-browser";
  humanName = "Glide Browser";
  mkTarget = import "${inputs.stylix}/stylix/mk-target.nix" { inherit name humanName; };
  colors = config.lib.stylix.colors;
  inherit (lib) mkEnableOption mkIf genAttrs;
  cfg = config.stylix.targets.glide-browser;
  mkColor = color: "rgb(${colors."${color}-rgb-r"},${colors."${color}-rgb-g"},${colors."${color}-rgb-b"})";

  nativeTheme = {
    # taken from: https://github.com/nix-community/stylix/blob/a378e4c09031fb15a4d65da88aa628f71fc52f6b/modules/firefox/each-config.nix#L115
    title = "Stylix ${colors.description}";
    images.additional_backgrounds = [ "./bg-000.svg" ];
    colors = {
      toolbar = mkColor "base00";
      toolbar_text = mkColor "base05";
      frame = mkColor "base01";
      tab_background_text = mkColor "base05";
      toolbar_field = mkColor "base02";
      toolbar_field_text = mkColor "base05";
      tab_line = mkColor "base0D";
      popup = mkColor "base00";
      popup_text = mkColor "base05";
      button_background_active = mkColor "base04";
      frame_inactive = mkColor "base00";
      icons_attention = mkColor "base0D";
      icons = mkColor "base05";
      ntp_background = mkColor "base00";
      ntp_text = mkColor "base05";
      popup_border = mkColor "base0D";
      popup_highlight_text = mkColor "base05";
      popup_highlight = mkColor "base04";
      sidebar_border = mkColor "base0D";
      sidebar_highlight_text = mkColor "base05";
      sidebar_highlight = mkColor "base0D";
      sidebar_text = mkColor "base05";
      sidebar = mkColor "base00";
      tab_background_separator = mkColor "base0D";
      tab_loading = mkColor "base05";
      tab_selected = mkColor "base00";
      tab_text = mkColor "base05";
      toolbar_bottom_separator = mkColor "base00";
      toolbar_field_border_focus = mkColor "base0D";
      toolbar_field_border = mkColor "base00";
      toolbar_field_focus = mkColor "base00";
      toolbar_field_highlight_text = mkColor "base00";
      toolbar_field_highlight = mkColor "base0D";
      toolbar_field_separator = mkColor "base0D";
      toolbar_vertical_separator = mkColor "base0D";
    };
  };
in
{
  imports = [
    (lib.modules.importApply "${inputs.stylix}/modules/firefox/each-config.nix" { inherit mkTarget name humanName; })
  ];

  options.stylix.targets.glide-browser = {
    glideNativeColors = {
      enable = mkEnableOption "Enable native browser color theme via {file}`glide.ts` configuration.";
    };
  };

  config.programs.glide-browser.profiles = mkIf cfg.glideNativeColors.enable (
    genAttrs cfg.profileNames (_: {
      glideTs = /* ts */ ''
        const theme_path = '${pkgs.writers.writeJSON "theme.json" nativeTheme}'
        glide.autocmds.create("ConfigLoaded", async () => {
          const raw = await glide.fs.read(theme_path, 'utf8')
          const theme = JSON.parse(raw)
          console.log("updating browser theme to:", theme)
          browser.theme.update(theme)
        })
      '';
    })
  );
}
