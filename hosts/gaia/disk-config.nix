{
  disko.devices = {
    disk.vdb = {
      device = "/dev/disk/by-id/mmc-SC32G_0x52ddc32f";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          firmware = {
            priority = 1;
            type = "EF00";
            start = "8M";
            end = "40M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/firmware";
            };
            hybrid = {
              mbrPartitionType = "0x0b";
              mbrBootableFlag = false;
            };
          };

          root = {
            size = "100%";
            content = {
              type = "btrfs";
              mountOptions = [ "noatime" "compress=zstd" "space_cache=v2" "discard" ];
              subvolumes = {
                "@nix" = { mountpoint = "/nix"; };
                "@persist" = { mountpoint = "/persist"; };
                "@swap" = { mountpoint = "/swap"; };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };
  };
}
