{ inputs, ... }:
{
  flake.modules.nixos."hosts/athena" = {
    imports = with inputs.hardware.nixosModules; [
      common-pc-laptop
      common-cpu-intel
      common-pc-ssd
    ];

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
    };

    services.libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
      };
      touchpad = {
        tapping = true;
        accelSpeed = "0.3";
      };
    };

    # stylus support not needed
    services.iptsd.enable = false;

    # needed for Windows dual boot
    time.hardwareClockInLocalTime = true;

    powerManagement.powertop.enable = true;
    boot.kernelParams = [ "i915.enable_psr=1" "i915.enable_rc6=1" ];

    home-manager.sharedModules = [{
      programs.niri.settings.input.touchpad.scroll-factor = 0.3;
    }];
  };
}
