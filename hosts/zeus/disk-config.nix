{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-KINGSTON_SUV400S37240G_50026B72650FA814";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                # extraArgs = [ "-f" ]; # Override existing partition
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" "discard" ];
              };
            };
          };
        };
      };
    };
  };
}

