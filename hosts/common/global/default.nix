{ inputs, outputs, lib, config, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./locale.nix
    ./zsh.nix
    ./nix.nix
    ./auto-upgrade.nix
    ./openssh.nix
    ./sops.nix
    ./tailscale.nix
    ./udev.nix
    ./nh.nix
    ./optin-persistence.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  boot = lib.mkIf (config.nixpkgs.hostPlatform == "x86_64-linux") {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
  hardware.enableRedistributableFirmware = true;

  programs.light.enable = true;

  # TODO: separate into modules
  services.geoclue2.enable = true;
  services.avahi.enable = true;
  programs.dconf.enable = true;

  services.upower.enable = true;

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}
