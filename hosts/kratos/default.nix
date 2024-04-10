{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/optional/nvidia.nix
    ../common/optional/quietboot.nix
    ../common/optional/pipewire.nix
    ../common/optional/greetd.nix
    ../common/optional/docker.nix
    ../common/optional/envfs.nix

    ../common/users/akos
  ];

  networking.hostName = "kratos";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl.enable = true;

  services.upower.enable = true;

  virtualisation.docker.storageDriver = "btrfs";

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    neofetch
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
