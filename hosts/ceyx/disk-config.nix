{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for GRUB MBR
            };

            ESP = {
              name = "ESP";
              size = "512M";
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
}
