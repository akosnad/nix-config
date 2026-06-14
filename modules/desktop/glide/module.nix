{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  flake.modules.homeManager.base = { config, ... }:
    let
      cfg = config.programs.glide-browser;
    in
    {
      options.programs.glide-browser = {
        profiles = mkOption {
          type = types.attrsOf (
            types.submodule
              {
                options = {
                  glideTs = mkOption {
                    description = ''
                      TypeScript configuration appended to {file}`glide.ts`.
                    '';
                    type = types.lines;
                    default = "";
                  };
                };
              }

          );
        };
      };
      config = {
        home.file = lib.pipe cfg.profiles [
          (lib.filterAttrs (_: profile: profile.glideTs != ""))
          (lib.mapAttrs' (_: profile: lib.nameValuePair "${cfg.profilesPath}/${profile.path}/glide/glide.ts" { text = profile.glideTs; }))
        ];
      };
    };
}
