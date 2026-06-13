{ config, lib, ... }:
{
  perSystem = { system, ... }:
    {
      checks = lib.pipe config.flake.esphomeHosts [
        (lib.filterAttrs (_: config: config.config.buildPlatform == system))
        (lib.mapAttrs' (name: config: lib.nameValuePair "esphome-${name}" config.config.yaml))
      ];
    };
}
