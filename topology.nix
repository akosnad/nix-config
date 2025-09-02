{ config, lib, ... }:
let
  inherit (config.lib.topology)
    mkInternet mkConnection mkSwitch mkDevice;

  mkAp = name: mkDevice name {
    deviceType = "ap";
    icon = "devices.access-point";
    interfaceGroups = [ [ "wifi" ] [ "lan1" "lan2" "lan3" ] ];
    interfaces.wifi.physicalConnections = lib.mkForce [{ node = "gaia-wifi"; interface = "ap"; }];
  };
in
{
  renderers.elk.overviews.services.enable = false;
  renderers.elk.overviews.networks.enable = false;

  nodes.internet = mkInternet {
    connections = mkConnection "gaia" "wan0";
  };
  nodes.gaia-wifi = (mkInternet { }) // {
    name = "Gaia WiFi";
    interfaces = {
      "*" = {
        network = "gaia-wifi";
        sharesNetworkWith = [ (n: n == "gaia") ];
      };
      ap = {
        network = "gaia-wifi";
        sharesNetworkWith = [ (n: n == "gaia") ];
      };
    };
  };

  networks.gaia = {
    name = "Gaia LAN (Ethernet)";
    cidrv4 = "10.0.0.0/8";
  };
  networks.gaia-wifi = {
    name = "Gaia LAN (WiFi)";
    inherit (config.networks.gaia) cidrv4 cidrv6;
    style = {
      inherit (config.networks.gaia.style) primaryColor;
      secondaryColor = null;
      pattern = "dotted";
    };
  };

  # Switches
  nodes.gaia-switch = mkSwitch "Gaia LAN aggregate switch" {
    info = "TP-Link TL-SG1016";
    interfaceGroups = [
      [ "eth1" "eth2" "eth3" "eth4" "eth5" "eth6" "eth7" "eth8" ]
      [ "eth9" "eth10" "eth11" "eth12" "eth13" "eth14" "eth15" "eth16" ]
    ];
    connections = {
      eth1 = mkConnection "gaia" "br-lan";
      eth2 = mkConnection "alarm" "lan1";
      eth3 = mkConnection "ap-kert" "lan1";
      eth4 = mkConnection "arges" "lan1";
      eth5 = mkConnection "akos-szoba-switch" "eth1";
      eth6 = mkConnection "nagyszoba-switch" "eth1";
      eth7 = mkConnection "hyperion" "lan1";
      eth8 = mkConnection "ap-eloszoba" "lan1";
    };
  };
  nodes.akos-szoba-switch = mkSwitch "Ákos szoba switch" {
    info = "TP-Link TL-SG105";
    interfaceGroups = [ [ "eth1" "eth2" "eth3" "eth4" "eth5" ] ];
    connections = {
      eth2 = mkConnection "iris" "lan1";
      eth3 = mkConnection "persephone" "lan1";
      eth4 = mkConnection "kronos" "lan1";
      eth5 = mkConnection "kratos" "lan1";
    };
  };
  nodes.nagyszoba-switch = mkSwitch "Nagyszoba switch" {
    info = "TP-Link TL-SG105";
    interfaceGroups = [ [ "eth1" "eth2" "eth3" "eth4" "eth5" ] ];
    connections = {
      eth2 = mkConnection "Orion-lan" "lan1";
      eth3 = mkConnection "kalliope" "lan1";
      eth4 = mkConnection "Tecil" "lan1";
      eth5 = mkConnection "ap-nagyszoba" "lan1";
    };
  };

  # APs
  nodes.ap-kert = mkAp "Kert AP";
  nodes.ap-eloszoba = mkAp "Előszoba AP";
  nodes.ap-nagyszoba = mkAp "Nagyszoba AP";
}
