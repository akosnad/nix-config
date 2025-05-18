{ inputs, outputs, lib, config, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-topology.nixosModules.default
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
    ./certs.nix
    ./stylix.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  devices = lib.mkForce inputs.self.devices;

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
    inherit (config.networking) hostName;
  };
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  home-manager.backupFileExtension = "hm-backup";

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  boot = lib.mkIf (config.nixpkgs.hostPlatform.system == "x86_64-linux") {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
  hardware.enableRedistributableFirmware = true;

  networking.domain = lib.mkDefault "home.arpa";

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

  # TODO: remove workaround after upstream patch is available
  # https://nixpk.gs/pr-tracker.html?pr=398397
  systemd.shutdownRamfs.enable = lib.mkForce false;
}
