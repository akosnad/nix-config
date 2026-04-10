{ config, lib, ... }:
{
  flake.modules.nixos."hosts/ceyx" = {
    # imports = [
    #   ./pocket-id.nix
    # ];
    imports = with config.flake.modules.nixos; [
      # profiles
      base
      akos
      server

      # boot
      ephemeral-btrfs

      # services
      vpn-server
      auth-server
    ] ++ [{
      home-manager.users.akos = {
        imports = with config.flake.modules.homeManager; [
          # profiles
          base
          akos
        ];
      };
    }];

    systemd.machineId = "08c9987365e3436cb8da48f7053045f5";

    boot.loader = {
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce true;
    };

    # backup access if headscale goes down
    services.openssh.openFirewall = lib.mkForce true;

    services.nginx.enable = true;
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    security.acme.defaults = lib.mkForce {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
      email = "contact@fzt.one";
    };

    sops.secrets.restic-persist-password.sopsFile = ./secrets.yaml;

    topology.self = {
      icon = "devices.cloud-server";
      hardware.info = "MikroVPS HU/KVM-1G";
      interfaces.ens18.physicalConnections = [
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
