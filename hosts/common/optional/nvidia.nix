{ config, lib, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.extraModprobeConfig =
    "options nvidia " + lib.concatStringsSep " " [
      "NVreg_UsePageAttributeTable=1"
      "NVreg_EnablePCIeGen3=1"
      "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
    ];
}
