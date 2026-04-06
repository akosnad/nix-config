{ inputs, ... }:
{
  flake.modules.nixos."hosts/kratos" = { pkgs, ... }: {
    imports = with inputs.hardware.nixosModules; [
      common-cpu-amd
      common-cpu-amd-pstate
      common-gpu-amd
      common-pc-ssd
    ];

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];

    services.libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
      };
    };

    # needed for Windows dual boot
    time.hardwareClockInLocalTime = true;
  };
}
