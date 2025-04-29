{ lib, self, ... }:
let
  inherit (lib) types mkOption;
  configurationModule = import "${self}/modules/common/esphome.nix";
in
{
  options.flake.esphomeConfigurations = mkOption {
    description = ''
      ESPHome device configurations.
    '';
    type = types.attrsOf (types.submodule configurationModule);
    default = { };
  };
}
