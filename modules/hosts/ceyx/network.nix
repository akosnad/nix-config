{ lib, ... }:
{
  config.flake.modules.nixos."hosts/ceyx" = {
    networking = {
      hostName = "ceyx";
      domain = "fzt.one";
    };

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
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"

      # fallback
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
