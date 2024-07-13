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
                mountOptions = [ "compress=zstd" "noatime" "discard" ];
                subvolumes = {
                  "@root" = { mountpoint = "/"; };
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
}

