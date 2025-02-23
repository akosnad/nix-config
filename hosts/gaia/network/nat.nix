{ config, lib, ... }:
let
  devices = builtins.attrValues config.devices;
  mapForward = d: fp: proto: { destination = "${d.ip}:${toString fp.dest}"; sourcePort = fp.source; inherit proto; };
  filterProto = target: candidate: target == candidate || candidate == "tcpudp";
  forwardsForProto = proto: map (d: map (fp: mapForward d fp proto) (builtins.filter (fp: filterProto proto fp.proto) d.forwardedPorts)) devices;

  forwardPorts = (lib.flatten (forwardsForProto "tcp")) ++ (lib.flatten (forwardsForProto "udp"));
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "br-lan" ];
    externalInterface = "wan0";
    inherit forwardPorts;
  };

  networking.nftables.tables = {
    nat-rndis = {
      family = "ip";
      content = /* nftables */ ''
        chain pre {
          type nat hook prerouting priority dstnat; policy accept;
        }

        chain post {
          type nat hook postrouting priority srcnat; policy accept;
          iifname "br-lan" oifname "wan-rndis" masquerade comment "from br-lan to wan-rndis";
        }

        chain out {
          type nat hook output priority mangle; policy accept;
        }
      '';
    };
    nat-rtp = {
      family = "ip";
      content = /* nftables */ ''
        chain pre {
          type nat hook prerouting priority dstnat; policy accept;

          iifname "wan0" udp dport 10000-20000 dnat to ${config.devices.hyperion.ip} comment "RTP to asterisk";
        }

        chain post {
          type nat hook postrouting priority srcnat; policy accept;

          ip saddr ${config.devices.hyperion.ip} udp dport 10000-20000 oifname "wan0" masquerade comment "from asterisk to wan0";
        }
      '';
    };
  };
}
