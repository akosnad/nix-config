{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/secureboot.nix

    ../common/users/akos
  ];

  networking.hostName = "hyperion";

  system.stateVersion = "24.11";
}
