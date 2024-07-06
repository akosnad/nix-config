{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    # TODO: removed until it's fixed
    # inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/optional/wireless.nix
    ../common/optional/powersave.nix
    ../common/optional/use-builders.nix
    ../common/optional/quietboot.nix
    ../common/optional/secureboot.nix
    ../common/optional/pipewire.nix
    ../common/optional/greetd.nix
    ../common/optional/docker.nix
    ../common/optional/wireshark.nix

    ../common/users/akos
  ];

  networking.hostName = "athena";
  networking.networkmanager.enable = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
  };

  services.libinput = {
    enable = true;
    touchpad.tapping = true;
  };


  # TODO: Imported options from hardware/common/common-gpu-intel
  # until it's fixed
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl intel-media-driver ];
  };
  environment.variables = {
    VDPAU_DRIVER = "va_gl";
  };

  # needed for Windows dual boot
  time.hardwareClockInLocalTime = true;

  powerManagement.powertop.enable = true;

  systemd.services.docker = {
    enable = true;
    # Only start docker when the socket is first accessed
    wantedBy = lib.mkForce [ ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
