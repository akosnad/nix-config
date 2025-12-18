_:
{ lib, ... }:
let
  inherit (lib) types mkOption;
  configurationModule = lib.modules.importApply ../common/devices.nix { };
in
{
  options.flake.devices = mkOption {
    description = ''
      Attributes of devices that get referenced throughout various configurations or present on the local network.
    '';
    type = types.attrsOf (types.submodule configurationModule);
    default = { };
  };
}
