{ lib, modulesPath, ... }:
let
  btrfsCommonMountOptions = [ "noatime" "compress=zstd" "space_cache=v2" "discard" ];
  mkBtrfsSubvolumeMount = name: {
    device = "/dev/disk/by-label/gaia";
    fsType = "btrfs";
    options = btrfsCommonMountOptions ++ [ "subvol=@${name}" ];
  };
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd = {
    availableKernelModules = [ "xhci_pci" ];
    kernelModules = [ ];
    supportedFilesystems = [ "btrfs" ];
  };
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "ext4";
      neededForBoot = true;
    };

    "/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

    "/nix" = mkBtrfsSubvolumeMount "nix";
    "/swap" = mkBtrfsSubvolumeMount "swap";
    "/" = mkBtrfsSubvolumeMount "root";
    "/persist" = mkBtrfsSubvolumeMount "persist" // { neededForBoot = true; };
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8 * 1024;
  }];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
