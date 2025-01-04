{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "67.207.67.3" "67.207.67.2" ];
    defaultGateway = "165.227.144.1";
    defaultGateway6 = {
      address = "";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = "165.227.156.239"; prefixLength = 20; }
          { address = "10.19.0.5"; prefixLength = 16; }
        ];
        ipv6.addresses = [
          { address = "fe80::41c:1aff:febd:c03d"; prefixLength = 64; }
        ];
        ipv4.routes = [{ address = "165.227.144.1"; prefixLength = 32; }];
        ipv6.routes = [{ address = ""; prefixLength = 128; }];
      };
      eth1 = {
        ipv4.addresses = [
          { address = "10.135.0.2"; prefixLength = 16; }
        ];
        ipv6.addresses = [
          { address = "fe80::984a:d8ff:fe8c:2e8c"; prefixLength = 64; }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="06:1c:1a:bd:c0:3d", NAME="eth0"
    ATTR{address}=="9a:4a:d8:8c:2e:8c", NAME="eth1"
  '';
}
