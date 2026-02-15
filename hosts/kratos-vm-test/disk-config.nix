{ inputs, ... }:
let
  zfs-storage-dev =
    { device }:
    {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
    };
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
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
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                  "space_cache=v2"
                  "discard"
                ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@old_roots" = { };
                  "@nix" = {
                    mountpoint = "/nix";
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                  };
                };
              };
            };
          };
        };
      };

      data1 = zfs-storage-dev {
        device = "/dev/vdb";
      };
      data2 = zfs-storage-dev {
        device = "/dev/vdc";
      };
    };

    zpool.storage = {
      type = "zpool";
      mode.topology = {
        type = "topology";
        vdev = [
          {
            mode = "mirror";
            members = [
              "data1"
              "data2"
            ];
          }
        ];
      };

      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
      };
      mountpoint = "/storage";
      datasets = {
        foo = {
          type = "zfs_fs";
          mountpoint = "/storage/foo";
        };
      };
    };
  };

  boot.zfs.devNodes = "/dev/disk/by-label";
  fileSystems."/persist".neededForBoot = true;
}
