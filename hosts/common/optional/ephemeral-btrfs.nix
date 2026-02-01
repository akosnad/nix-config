{ lib, config, inputs, ... }:
let
  systemdRootDevice = (lib.pipe config.fileSystems."/".device [
    (lib.removePrefix "/")
    (lib.replaceStrings [ "/" "-" ] [ "-" "\\x2d" ])
  ]) + ".device";

  wipeScript = /* bash */ ''
    mkdir -p /tmp
    MNTPOINT=$(mktemp -d)

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "$MNTPOINT/$i"
        done
        btrfs subvolume delete "$1"
    }

    (
      mount -t btrfs "${config.fileSystems."/".device}" "$MNTPOINT"
      trap 'echo "Done"; umount "$MNTPOINT"' EXIT

      echo "Creating needed directories..."
      mkdir -p "$MNTPOINT"/@persist/var/{log,lib/{nixos,systemd}}
      if [ -e "$MNTPOINT/@persist/dont-wipe" ]; then
        echo "Skipping wipe"
      else
        echo "Backing up old root..."
        timestamp=$(date --date="@$(stat -c %Y "$MNTPOINT/@root")" "+%Y-%m-%-d_%H:%M:%S")
        mv "$MNTPOINT/@root" "$MNTPOINT/@old_roots/$timestamp"

        echo "Cleaning up old roots..."
        for i in $(find $MNTPOINT/@old_roots/ -maxdepth 1 -mtime +30); do
          echo "Deleting $i..."
          delete_subvolume_recursively "$i"
        done

        echo "Creating blank root..."
        btrfs subvolume create "$MNTPOINT"/@root
      fi
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkAfter wipeScript);
    systemd.services.restore-root = lib.mkIf phase1Systemd {
      description = "Rollback btrfs rootfs";
      wantedBy = [ "initrd.target" ];
      requires = [ systemdRootDevice ];
      after = [ systemdRootDevice ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = wipeScript;
    };
  };
}
