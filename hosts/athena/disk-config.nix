{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  boot.initrd = {
    systemd.enable = true;
    luks.fido2Support = false; # systemd handles FIDO2
    luks.devices.root.crypttabExtraOpts = [ "fido2-device=auto" ];
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZ9LQ1T0HBLB-00B00_S7DCNXMW141190";
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
                type = "luks";
                name = "root";
                settings = {
                  allowDiscards = true;
                };
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
  };

  fileSystems."/persist".neededForBoot = true;
}
