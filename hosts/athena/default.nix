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
    ../common/optional/quietboot.nix
    ../common/optional/pipewire.nix
    ../common/optional/greetd.nix
    ../common/optional/docker.nix
    ../common/optional/wireshark.nix

    ../common/users/akos
  ];

  networking.hostName = "athena";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
  };

  hardware.opengl.enable = true;

  powerManagement.powertop.enable = true;
  services.upower.enable = true;

  services.xserver.libinput = {
    enable = true;
    touchpad.tapping = true;
  };


  systemd.services.docker = {
    enable = true;
    # Only start docker when the socket is first accessed
    wantedBy = lib.mkForce [ ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    neofetch
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
