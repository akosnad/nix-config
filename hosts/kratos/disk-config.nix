{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W941031H";
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
}
