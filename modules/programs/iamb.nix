{ inputs, ... }:
{
  flake.modules.homeManager.iamb =
    { config, ... }:
    {
      programs.iamb = {
        enable = true;
        settings = {
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

      home.persistence."/persist".directories = [
        ".local/share/iamb"
        ".cache/iamb/profiles"
      ];
    };

  flake.overlays.iamb-unstable = final: _prev:
    let
      pkgsUnstable = import inputs.nixpkgs-unstable {
        config = import ../base/nixpkgs/_nixpkgs-config.nix;
        system = final.stdenv.hostPlatform.system;
      };
    in
    {
      inherit (pkgsUnstable) iamb;
    };
}
