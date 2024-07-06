{ inputs, outputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./optin-persistence.nix
    ./locale.nix
    ./zsh.nix
    ./nix.nix
    ./auto-upgrade.nix
    ./openssh.nix
    ./sops.nix
    ./tailscale.nix
    ./udev.nix
    ./nh.nix
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
