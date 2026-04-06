{ inputs, lib, config, ... }:
let
  prefix = "hosts/";
in
{
  config.flake.esphomeHosts = lib.pipe config.flake.modules.esphome [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module:
        let
          hostName = lib.removePrefix prefix name;
          specialArgs = {
            inherit inputs;
            hostConfig = {
              name = hostName;
            };
          };
        in
        {
          name = hostName;
          value = lib.evalModules {
            inherit specialArgs;
            modules = [
              ./_module-options.nix
              module
            ];
            class = "esphome";
          };
        }
    ))
  ];
}
