{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix

    ../common/users/akos
  ];

  networking.hostName = "kratos-vm-test";
  networking.hostId = "17f24c9c";

  users.users.root.password = "root";

  system.stateVersion = "24.11";
}
