{ inputs
, lib
, pkgs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

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
    ../common/optional/nautilus.nix
    ../common/optional/nix-cache-proxy.nix

    ../common/users/akos
  ];

  networking.hostName = "athena";
  networking.networkmanager.enable = true;

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

  systemd.services.docker = {
    enable = true;
    # Only start docker when the socket is first accessed
    wantedBy = lib.mkForce [ ];
  };
  virtualisation.docker.storageDriver = "btrfs";

  programs.nh.clean.enable = false;

  # needed to open for firewall
  programs.kdeconnect.enable = true;

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-dark.yaml";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
