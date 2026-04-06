{ config, ... }:
{
  config.flake.modules.nixos."hosts/uranus" = {
    imports = with config.flake.modules.nixos; [
      # profiles
      base
      akos
      server

      # boot
      ephemeral-btrfs

      # services
      arion
      docker-watchtower
    ] ++ [{
      home-manager.users.akos = {
        imports = with config.flake.modules.homeManager; [
          # profiles
          base
          akos
        ];
      };
    }];

    networking.hostName = "uranus";
    systemd.machineId = "6699fe5fe98b45a0a5d801ec522bf83e";

    topology.self = {
      icon = "devices.cloud-server";
      hardware.info = "Vultr 2048.00 MB Regular Cloud Compute";
      interfaces.enp1s0.physicalConnections = [
        {
          node = "internet";
          interface = "*";
          renderer.reverse = true;
        }
      ];
    };

    system.stateVersion = "24.11";
  };
}
