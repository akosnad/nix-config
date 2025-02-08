{ pkgs, ... }:
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
        notifications = {
          enabled = true;
          show_message = true;
          via = "desktop";
        };
      };

      layout.style = "restore";
    };
  };

  sops.secrets = {
    matrix-password = { };
  };
}
