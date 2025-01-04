{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ../common/global
    ../common/users/akos
  ];

  networking.hostName = "ocean";

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-diskseq/1";
  };

  environment.persistence."/persist".enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
