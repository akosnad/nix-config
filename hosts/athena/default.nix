{ inputs
, lib
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.microsoft-surface-pro-intel

    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/wireless.nix
    ../common/optional/powersave.nix
    ../common/optional/use-builders.nix
    ../common/optional/quietboot.nix
    ../common/optional/secureboot.nix
    ../common/optional/pipewire.nix
    ../common/optional/greetd.nix
    ../common/optional/docker
    ../common/optional/wireshark.nix
    ../common/optional/yubikey.nix
    ../common/optional/xwayland-fix.nix
    ../common/optional/bluetooth.nix
    ../common/optional/printing.nix

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
    touchpad = {
      tapping = true;
      accelSpeed = 0.3;
    };
  };

  # stylus support not needed
  services.iptsd.enable = false;

  # needed for Windows dual boot
  time.hardwareClockInLocalTime = true;

  powerManagement.powertop.enable = true;

  systemd.services.docker = {
    enable = true;
    # Only start docker when the socket is first accessed
    wantedBy = lib.mkForce [ ];
  };
  virtualisation.docker.storageDriver = "btrfs";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
