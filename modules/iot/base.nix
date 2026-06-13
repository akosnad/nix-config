{ lib, ... }:
{
  flake.modules.esphome.base = { name, ... }: {
    settings = {
      esphome = {
        name = lib.mkDefault name;
        project.name = "akosnad.nix-config";
      };
      ota = {
        platform = "esphome";
        password = "!secret ota_pass";
      };
      logger = { };
      api = { };
    };
  };
}
