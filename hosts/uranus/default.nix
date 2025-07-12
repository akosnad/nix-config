{ lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/high-availability.nix
    ../common/optional/docker
    ../common/optional/docker/watchtower.nix
    ../common/optional/docker/arion.nix

    ../common/users/akos

    ./matrix
    ./backup.nix
    ./miniflux.nix
    ./deploy.nix
    ./personal-site.nix
  ];

  networking.hostName = "uranus";

  swapDevices = [{
    device = "/swap/swapfile";
    size = 8 * 1024;
  }];

  services.journald.extraConfig = ''
    SystemMaxUse=5G
    SystemKeepFree=1G
  '';

  services.openssh.openFirewall = lib.mkForce false;

  security.acme.defaults = lib.mkForce {
    server = "https://acme-v02.api.letsencrypt.org/directory";
    validMinDays = 30;
    email = "contact@fzt.one";
  };

  services.cloudflared = {
    enable = true;
    certificateFile = config.sops.secrets.cloudflared-cert.path;
    tunnels.uranus = {
      default = "http_status:404";
      credentialsFile = config.sops.secrets.cloudflared-creds.path;
    };
  };

  sops.secrets.cloudflared-cert = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets.cloudflared-creds = {
    sopsFile = ./secrets.yaml;
  };

  topology.self = {
    icon = "devices.cloud-server";
    hardware.info = "Vultr 2048.00 MB Regular Cloud Compute";
    interfaces.enp1s0.physicalConnections = [
      { node = "internet"; interface = "*"; renderer.reverse = true; }
    ];
  };

  system.stateVersion = "24.11";
}
