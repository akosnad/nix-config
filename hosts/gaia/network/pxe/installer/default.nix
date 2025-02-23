system: { inputs, pkgs, lib, config, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/all-hardware.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/installation-device.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  boot.loader.grub.enable = false;

  fileSystems."/" = lib.mkImageMediaOverride {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  fileSystems."/nix/.rw-store" = lib.mkImageMediaOverride {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
    neededForBoot = true;
  };

  fileSystems."/nix/store" = lib.mkImageMediaOverride {
    overlay = {
      lowerdir = [ "/nix/.ro-store" ];
      upperdir = "/nix/.rw-store/store";
      workdir = "/nix/.rw-store/work";
    };
    neededForBoot = true;
  };

  # available to load
  boot.initrd.availableKernelModules = [ "e1000e" ];
  # always loaded
  boot.initrd.kernelModules = [ "nfs" "nfsv4" "nfsd" "sunrpc" "overlay" ];
  boot.initrd.supportedFilesystems = {
    nfs = true;
    nfsv4 = true;
    overlay = true;
  };
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true;
    network = {
      enable = true;
      wait-online.enable = true;
      networks."99-dhcp-all" = {
        matchConfig.Name = "*";
        networkConfig.DHCP = "yes";
      };
    };
    storePaths = with pkgs; [ nfs-utils ];
    services = {
      mount-remote-nix-store = {
        script = ''
          mkdir -p -m755 /sysroot/nix/.ro-store
          ${lib.getExe' pkgs.nfs-utils "mount.nfs4"} -r -o defaults,ro,noatime,_netdev 10.0.0.1:/nix/store /sysroot/nix/.ro-store
        '';
        requiredBy = [ "sysroot-nix-store.mount" "initrd-fs.target" ];
        before = [ "sysroot-nix-store.mount" "initrd-fs.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
  };

  boot.postBootCommands = ''
    # After booting, register the contents of the Nix store
    # in the Nix database in the tmpfs.
    ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

    # nixos-rebuild also requires a "system" profile and an
    # /etc/NIXOS tag.
    touch /etc/NIXOS
    ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

    # Set password for user nixos if specified on cmdline
    # Allows using nixos-anywhere in headless environments
    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwordHash=*)
          set -- $(IFS==; echo $o)
          ${pkgs.gnugrep}/bin/grep -q "root::" /etc/shadow && ${pkgs.shadow}/bin/usermod -p "$2" root
          ;;
        live.nixos.password=*)
          set -- $(IFS==; echo $o)
          ${pkgs.gnugrep}/bin/grep -q "root::" /etc/shadow && echo "root:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = system;

  environment.systemPackages = with pkgs; [
    helix
  ];

  system.stateVersion = "24.11";
}
