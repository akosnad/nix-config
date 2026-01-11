{ lib, config, ... }: {
  imports = [
    ../common/global
    ../common/users/akos

    ./docker-desktop.nix
  ];

  environment.persistence."/persist".enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  wsl = {
    enable = true;
    defaultUser = "akos";
    wslConf.automount.options = "metadata,uid=${toString config.users.users.akos.uid},gid=${toString config.users.groups.users.gid},umask=002,dmask=002,fmask=002";
  };
  networking.hostName = "work-laptop";
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = "x86_64-linux";

  topology.self = {
    icon = "devices.wsl";
    hardware.info = "ThinkPad P14s Gen 5";
    interfaces.wifi.physicalConnections = [
      { node = "internet"; interface = "*"; renderer.reverse = true; }
    ];
  };

  system.stateVersion = "25.05";


}
