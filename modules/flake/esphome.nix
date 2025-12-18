_:
{ lib, withSystem, ... }:
let
  inherit (lib) types mkOption;

  # TODO: hack to obtain pkgs outside `perSystem`.
  # this currently assumes that the target system is x86_64-linux.
  # so building ESPHome firmwares using this module will only work on x86_64-linux for now.
  pkgs = (withSystem "x86_64-linux") ({ pkgs, ... }: pkgs);

  configurationModule = lib.modules.importApply ../common/esphome.nix { inherit pkgs; };
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
