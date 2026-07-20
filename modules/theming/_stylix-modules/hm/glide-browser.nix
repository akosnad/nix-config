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
    title = "Stylix: ${colors.scheme} - ${colors.description}";
    images.additional_backgrounds = [ "./bg-000.svg" ];
    colors = lib.mapAttrs (_: mkColor) {
      toolbar = "base00";
      toolbar_text = "base05";
      frame = "base01";
      tab_background_text = "base05";
      toolbar_field = "base02";
      toolbar_field_text = "base05";
      tab_line = "base0D";
      popup = "base00";
      popup_text = "base05";
      button_background_active = "base04";
      frame_inactive = "base00";
      icons_attention = "base0D";
      icons = "base05";
      ntp_background = "base00";
      ntp_text = "base05";
      popup_border = "base0D";
      popup_highlight_text = "base05";
      popup_highlight = "base04";
      sidebar_border = "base0D";
      sidebar_highlight_text = "base05";
      sidebar_highlight = "base0D";
      sidebar_text = "base05";
      sidebar = "base00";
      tab_background_separator = "base0D";
      tab_loading = "base05";
      tab_selected = "base00";
      tab_text = "base05";
      toolbar_bottom_separator = "base00";
      toolbar_field_border_focus = "base0D";
      toolbar_field_border = "base00";
      toolbar_field_focus = "base00";
      toolbar_field_highlight_text = "base00";
      toolbar_field_highlight = "base0D";
      toolbar_field_separator = "base0D";
      toolbar_vertical_separator = "base0D";
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

  config = {
    home.file = mkIf cfg.glideNativeColors.enable (
      genAttrs (map (x: ".config/glide/glide/${x}/glide/theme.json") cfg.profileNames) (_: {
        source = pkgs.writers.writeJSON "theme.json" nativeTheme;
      })
    );

    programs.glide-browser.profiles = mkIf cfg.glideNativeColors.enable (
      genAttrs cfg.profileNames (profileName: {
        glideTs = /* ts */ ''
          const theme_path = 'theme.json'

          async function load_theme() {
            const raw = await glide.fs.read(theme_path, 'utf8')
            const theme = JSON.parse(raw)
            console.log("updating browser theme to:", theme)
            browser.theme.update(theme)
          }
          glide.autocmds.create("ConfigLoaded", load_theme)

          async function theme_change_watcher() {
            try {
              while(true) {
                  await glide.process.execute("${lib.getExe' pkgs.inotify-tools "inotifywait"}", ['-P', '-e', 'attrib', '${config.xdg.configHome}/glide/glide/${profileName}/glide/theme.json'])
                  await load_theme()
              }
            } catch (e) {
              console.error(e)
            }
          }
          glide.autocmds.create("WindowLoaded", theme_change_watcher)
        '';
      })
    );
  };
}
