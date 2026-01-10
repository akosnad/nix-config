{ nfsRemote, system }:
args @ { inputs, lib, pkgs, ... }:
let
  gpgKeyDerivation = pkgs.callPackage ../../../../../home/akos/gpg-key.nix args;
  gpgSshKey = builtins.readFile "${gpgKeyDerivation}/ssh.pub";
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/installation-device.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  hardware.enableAllHardware = true;

  boot.loader.grub.enable = false;
  boot.initrd.supportedFilesystems = [ "nfs" "nfsv4" "overlay" ];
  boot.initrd.kernelModules = [ "nfs" "nfsv4" "overlay" ];
  boot.initrd.availableKernelModules = [ "r8169" ];

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  fileSystems."/nix/.rw-store" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
    neededForBoot = true;
  };

  fileSystems."/nix/.ro-store" = {
    fsType = "nfs4";
    options = [ "ro" "noatime" ];
    device = "${nfsRemote}:/nix/store";
    neededForBoot = true;
  };

  fileSystems."/nix/store" = {
    overlay = {
      lowerdir = [ "/nix/.ro-store" ];
      upperdir = "/nix/.rw-store/store";
      workdir = "/nix/.rw-store/work";
    };
    depends = [
      "/nix/.ro-store"
      "/nix/.rw-store/store"
      "/nix/.rw-store/work"
    ];
  };

  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.nfs-utils}/bin/mount.nfs
    copy_bin_and_libs ${pkgs.nfs-utils}/bin/mount.nfs4
    copy_bin_and_libs ${pkgs.nfs-utils}/bin/nfsstat
  '';
  boot.initrd.network = {
    enable = true;
    flushBeforeStage2 = false;
  };
  networking.useDHCP = lib.mkForce true;

  boot.postBootCommands = ''
    touch /etc/NIXOS

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

  users.users.root = {
    openssh.authorizedKeys.keys = [ gpgSshKey ];
  };

  services.getty.helpLine = lib.mkForce ''
    Welcome to installer

    Booted from ${nfsRemote}
    System is ${system}
  '';

  systemd.shutdownRamfs.enable = false;

  nix.settings = {
    experimental-features = "nix-command flakes";
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
      "https://nix.fzt.one/"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix.fzt.one-1:W6+n+PqYiAINgEUYnAxoDrV0xrjPR0C0fJeIDp3nvAw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = system;

  environment.systemPackages = with pkgs; [
    # editing
    helix
    git

    # disk usage tools
    ncdu
    duf
    dust

    # piping, searching, file utilities
    jq
    ripgrep
    file
    fd
    yazi

    # system monitoring
    htop
    glances

    # network debugging
    iftop
    iperf3
    gping
    curlie
    doggo

    # nix utilities
    nvd
    nix-tree
  ];

  networking.hostName = "installer";
  system.stateVersion = "24.11";
}
