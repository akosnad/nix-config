{ config, lib, ... }:
let
  devices = config.flake.devices;
in
{
  flake.modules.esphome.w5500 = { name, ... }:
    let
      isLocalDevice = lib.hasAttr name devices;
    in
    {
      settings = {
        ethernet = {
          type = "W5500";
          mac_address = lib.mkIf isLocalDevice devices.${name}.mac;
          manual_ip = lib.mkIf isLocalDevice {
            static_ip = devices.${name}.ip;
            subnet = "255.0.0.0";
            gateway = devices.gaia.ip;
            dns1 = devices.gaia.ip;
          };
        };
      };
    };
}
