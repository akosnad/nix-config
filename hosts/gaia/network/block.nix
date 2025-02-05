{ config, ... }:
let
  devices = builtins.attrValues config.devices;
  macAddrsToBlock = map (d: d.mac) (builtins.filter (d: d.mac != null && d.blockInternetAccess.mac) devices);
  ipAddrsToBlock = map (d: d.ip) (builtins.filter (d: d.ip != null && d.blockInternetAccess.ip) devices);

  externalInterfaces = [ "wan0" "wan-rndis" ];

  macRules = builtins.concatMap (int: map (mac: "oifname \"${int}\" ether saddr ${mac} drop comment \"device blocked internet access\";") macAddrsToBlock) externalInterfaces;
  ipRules = builtins.concatMap (int: map (ip: "oifname \"${int}\" ip saddr ${ip} drop comment \"device blocked internet access\";") ipAddrsToBlock) externalInterfaces;
in
{
  networking.nftables.tables = {
    block-devices = {
      family = "ip";
      content = /* nftables */ ''
        chain forward {
          type filter hook forward priority 0; policy accept;

          ${builtins.concatStringsSep "\n  " macRules}
          ${builtins.concatStringsSep "\n  " ipRules}
        }
      '';
    };
  };
}
