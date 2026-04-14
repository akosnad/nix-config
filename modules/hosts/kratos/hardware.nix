{
  flake.modules.nixos."hosts/kratos" = { pkgs, ... }: {
    hardware.facter.reportPath = ./facter.json;

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
