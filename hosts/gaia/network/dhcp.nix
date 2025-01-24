{ config, lib, ... }:
let
  gatewayIp = "10.20.0.1";
  dhcpRange = {
    ipPrefix = "10.20.0";
    lower = "10";
    upper = "254";
    leaseTime = "1h";
  };
  inherit (config.networking) domain;

  staticLeaseDevices = lib.filterAttrs
    (_: d:
      if d.local && (d.hostname == null || d.mac == null || d.ip == null) then
        throw ''
          Local device definition missing MAC, IP or hostname.
          All of the above are needed to be able to lease a static IP to them.
        ''
      else d.local
    )
    (lib.filterAttrs (_: d: d.hostname != config.networking.hostName) # exclude ourselves from list
      config.devices);
  staticLeases = builtins.attrValues staticLeaseDevices;

  mapExtraHostnames = d: eh: lib.flatten ([ d.hostname "${d.hostname}.${config.networking.domain}" ] ++ (map (h: [ h "${h}.${domain}" ]) eh));
  deviceHostnames = lib.mapAttrs' (_: d: { name = d.ip; value = mapExtraHostnames d d.extraHostnames; }) config.devices;
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = "";

      dhcp-range = with dhcpRange; [ "set:lan,${ipPrefix}.${lower},${ipPrefix}.${upper},${leaseTime}" ];
      dhcp-option = [
        # Gateway
        "lan,3,${gatewayIp}"
        # DNS server
        "lan,6,${gatewayIp}"
      ];

      # Static leases
      dhcp-host = builtins.map (device: "${device.mac},lan,${device.ip},${device.hostname}") staticLeases;
    };
  };

  networking.hosts = deviceHostnames;
}
