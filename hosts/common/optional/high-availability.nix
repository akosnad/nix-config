{ config, lib, ... }:
let
  dockerEnabled = config.virtualisation.docker.enable;
  podmanEnabled = config.virtualisation.podman.enable;
  autoUpgradeEnabled = config.system.autoUpgrade.enable;

  autoPrune = {
    enable = true;
    dates = "weekly";
    flags = [ "--all" ];
  };
in
{
  virtualisation.docker = lib.mkIf dockerEnabled {
    enableOnBoot = true;

    # fixes broken networking after a nixos-rebuild switch
    # because containers are restarted
    daemon.settings."live-restore" = false;

    inherit autoPrune;
  };

  virtualisation.podman = lib.mkIf podmanEnabled {
    inherit autoPrune;
  };

  system.autoUpgrade = lib.mkIf autoUpgradeEnabled {
    allowReboot = true;
    operation = "switch";
    dates = "*:0/15"; # every 15 mins
    rebootWindow = {
      lower = "03:00";
      upper = "06:00";
    };
  };
}
