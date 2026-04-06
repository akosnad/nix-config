{
  config.flake.modules.nixos."hosts/hyperion" = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/ata-INTEL_SSDSC2BP240G4_BTJR40960G96240AGN";
          content = {
            type = "gpt";
            partitions = {

              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "513M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };

              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  mountOptions = [ "noatime" "compress=zstd" "space_cache=v2" "discard" ];
                  subvolumes = {
                    "@root" = { mountpoint = "/"; };
                    "@old_roots" = { };
                    "@nix" = { mountpoint = "/nix"; };
                    "@persist" = { mountpoint = "/persist"; };
                    "@swap" = { mountpoint = "/swap"; };
                  };
                };
              };
            };
          };
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;

    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs = {
      devNodes = "/dev/disk/by-partlabel";
      extraPools = [ "thesauros" ];
      forceImportRoot = false;
    };
    networking.hostId = "3526dac2";

    swapDevices = [
      {
        device = "/swap/swapfile";
        size = 32 * 1024;
      }
    ];

    virtualisation.docker.storageDriver = "btrfs";
  };
}
