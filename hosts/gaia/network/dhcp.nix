{ config, lib, ... }:
let
  inherit (config.networking) domain;
  gatewayIp = config.devices.gaia.ip;

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
      port = "5953";
      dhcp-authoritative = true;
      domain-needed = true;
      bogus-priv = true;
      expand-hosts = true;

      # serve in an unassigned address space for non-declared devices
      dhcp-range = [ "set:lan,10.99.0.1,10.99.254.254,10m" ];
      # Static leases
      dhcp-host = builtins.map (device: "${device.mac},set:lan,${device.ip},${device.hostname},infinite") staticLeases;
      # common options
      dhcp-option = [
        "tag:lan,option:netmask,255.0.0.0"
        "tag:lan,option:router,${gatewayIp}"
        "tag:lan,option:dns-server,${gatewayIp}"
        "tag:lan,option:domain-name,${domain}"
        "tag:lan,option:domain-search,${domain}"
        "tag:lan,option:sip-server,${config.devices.hyperion.ip}"
        "tag:lan,option:tzdb-timezone,Europe/Budapest"
      ];

    };
  };

  networking.hosts = deviceHostnames;
}
