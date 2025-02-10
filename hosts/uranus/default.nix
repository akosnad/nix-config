{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/high-availability.nix

    ../common/users/akos
  ];

  networking.hostName = "uranus";

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8 * 1024;
  }];

  services.openssh.openFirewall = lib.mkForce false;

  services.geoclue2.enable = lib.mkForce false;
  services.avahi.enable = lib.mkForce false;
  programs.dconf.enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
