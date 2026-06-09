{ nfsRemote, system }:
args @ { inputs, lib, pkgs, ... }:
let
  gpgKeyDerivation = pkgs.callPackage ../../../../../akos/_gpg-key.nix args;
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

  boot.initrd.systemd.storePaths = [ pkgs.nfs-utils ];
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
