{ lib, ... }:
{
  config.flake.modules.nixos.base = { config, ... }: {
    home-manager.backupFileExtension = "hm-backup";

    users.mutableUsers = false;

    boot = lib.mkIf (config.nixpkgs.hostPlatform.system == "x86_64-linux") {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
    hardware.enableRedistributableFirmware = true;

    networking.domain = lib.mkDefault "home.arpa";

    # TODO: separate into modules
    services.geoclue2.enable = true;
    services.avahi.enable = true;
    programs.dconf.enable = true;

    # TODO: remove workaround after upstream patch is available
    # https://nixpk.gs/pr-tracker.html?pr=398397
    systemd.shutdownRamfs.enable = lib.mkForce false;
  };
}
