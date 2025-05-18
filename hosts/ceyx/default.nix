{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../common/global
    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/high-availability.nix
    ../common/optional/fail2ban.nix

    ../common/users/akos
    ./headscale.nix
    ./backup.nix
  ];

  networking = {
    hostName = "ceyx";
    domain = "fzt.one";
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4 * 1024;
  }];

  networking.useDHCP = lib.mkForce false;
  networking.interfaces.ens18 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "185.112.157.190";
      prefixLength = 24;
    }];
    ipv6.addresses = [{
      address = "2a02:6080::1:542c:26ab";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway = {
    address = "185.112.157.254";
    interface = "ens18";
  };
  networking.defaultGateway6 = {
    address = "2a02:6080::1";
    interface = "ens18";
  };

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = lib.mkForce true;
  };

  # backup access if headscale goes down
  services.openssh.openFirewall = lib.mkForce true;

  services.geoclue2.enable = lib.mkForce false;
  services.avahi.enable = lib.mkForce false;
  programs.dconf.enable = lib.mkForce false;

  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme.defaults = lib.mkForce {
    server = "https://acme-v02.api.letsencrypt.org/directory";
    validMinDays = 30;
    email = "contact@fzt.one";
  };

  topology.self = {
    icon = "devices.cloud-server";
    hardware.info = "MikroVPS HU/KVM-1G";
    interfaces.ens18.physicalConnections = [
      { node = "internet"; interface = "*"; renderer.reverse = true; }
    ];
  };

  system.stateVersion = "24.11";
}
