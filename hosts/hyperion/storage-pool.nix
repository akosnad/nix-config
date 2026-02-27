{ lib, ... }:
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
  disko.devices = {
    disk = (lib.mapAttrs
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
      drives) // {
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
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
      };
      mountpoint = "/${poolname}";

      datasets = {
        zeusraid = {
          type = "zfs_fs";
          mountpoint = "/raid";
        };
      };
    };
  };
}
