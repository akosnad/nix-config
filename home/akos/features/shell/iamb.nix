{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    iamb
  ];

  xdg.configFile."iamb/config.toml" = {
    source = (pkgs.formats.toml { }).generate "iamb-config.toml" {
      default_profile = "default";
      profiles.default = {
        user_id = "@akosnad:m.fzt.one";
        url = "https://m.fzt.one";
      };

      settings = {
        image_preview.protocol.type = "kitty";
        username_display = "displayname";
      };

      layout.style = "restore";

      macros = {
        normal = {
          gc = ":chats<Enter>";
          gu = ":unreads<Enter>";
          gs = ":spaces<Enter>";
          gr = ":rooms<Enter>";
          gd = ":dms<Enter>";
        };
      };

      dirs.downloads = "${config.home.homeDirectory}/Downloads/iamb";
    };
  };
}
