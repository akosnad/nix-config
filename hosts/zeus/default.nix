{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/docker.nix
    ../common/optional/libvirt.nix
    ../common/optional/builder

    ../common/users/akos
  ];

  networking.hostName = "zeus";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.firewall = {
    allowedTCPPorts = [
      80 443 # webserver
      32400 8324 32469 # plex
    ];
    allowedUDPPorts = [
      1900 5353 32410 32412 32413 32414 # plex
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nomodeset" ];

  services.upower.enable = true;

  virtualisation.docker.storageDriver = "btrfs";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
