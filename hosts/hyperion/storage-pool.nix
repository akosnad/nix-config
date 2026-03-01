{ inputs, lib, ... }:
let
  poolname = "thesauros";
  drives = {
    data1 = "wwn-0x5000c500951a8c0b";
    data2 = "wwn-0x5000c500951a8d03";
    data3 = "wwn-0x5000c500951bda43";
    data4 = "wwn-0x5000c500951c1aa7";
    data5 = "wwn-0x5000c500951c9bcb";
    data6 = "wwn-0x5000c500951c84cb";
  };
in
{
  imports = [ inputs.disko-zfs.nixosModules.default ];

  disko = {
    devices = {
      disk =
        (lib.mapAttrs
          (_name: id: {
            type = "disk";
            device = "/dev/disk/by-id/${id}";
            content = {
              type = "gpt";
              partitions = {
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = poolname;
                  };
                };
              };
            };
          })
          drives)
        // {
          cache1 = {
            type = "disk";
            device = "/dev/disk/by-id/wwn-0x500151795958fc81";
            content = {
              type = "gpt";
              partitions = {
                zfs = {
                  size = "50G"; # overprovision the SSD
                  content = {
                    type = "zfs";
                    pool = poolname;
                  };
                };
              };
            };
          };
        };

      zpool.${poolname} = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz2";
                members = [
                  "data1"
                  "data2"
                  "data3"
                  "data4"
                  "data5"
                  "data6"
                ];
              }
            ];
            cache = [ "cache1" ];
          };
        };
        rootFsOptions = {
          acltype = "posix";
          atime = "off";
          xattr = "on";
          compression = "zstd";
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = rec {
          zeusraid = {
            type = "zfs_fs";
            mountpoint = "/raid";
            options.mountpoint = "legacy";
          };

          media = {
            type = "zfs_fs";
            options = {
              mountpoint = "/media";
              recordsize = "4M";
            };
          };
          "media/Radarr".type = "zfs_fs";
          "media/Sonarr".type = "zfs_fs";
          "media/Lidarr".type = "zfs_fs";
          "media/Music".type = "zfs_fs";
          "media/mediaklikk".type = "zfs_fs";
          "media/mediaklikk/scripts" = {
            type = "zfs_fs";
            options.recordsize = "4K";
          };

          torrents = {
            type = "zfs_fs";
            options = {
              mountpoint = "/torrents";
              recordsize = "256K";
            };
          };
          "torrents/Radarr" = {
            type = "zfs_fs";
            options.recordsize = media.options.recordsize;
          };
          "torrents/Sonarr" = {
            type = "zfs_fs";
            options.recordsize = media.options.recordsize;
          };
          "torrents/nCoreFilmek" = {
            type = "zfs_fs";
            options.recordsize = media.options.recordsize;
          };
          "torrents/nCoreSorozatok" = {
            type = "zfs_fs";
            options.recordsize = media.options.recordsize;
          };

          frigate = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/frigate";
              recordsize = "4K";
            };
          };
          "frigate/clips" = {
            type = "zfs_fs";
            options.recordsize = "1M";
          };
          "frigate/exports" = {
            type = "zfs_fs";
            options.recordsize = "4M";
          };
          "frigate/recordings" = {
            type = "zfs_fs";
            options.recordsize = "8M";
          };

          webarchive.type = "zfs_fs";
          backup.type = "zfs_fs";

          testvol = {
            type = "zfs_volume";
            size = "20G";
          };
        };
      };
    };
    zfs = {
      enable = true;
      settings.ignoredProperties = [ "nixos:shutdown-time" ];
    };
  };
}
