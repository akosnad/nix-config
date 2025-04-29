{ lib, config, ... } @ args:
let
  cfg = config.devices;
in
{
  options.devices = (import ../common/devices.nix args).options.devices;
  config = {
    assertions = [
      {
        assertion =
          let
            macs = builtins.filter (mac: mac != null) (map (d: d.mac) (builtins.attrValues cfg));
          in
          lib.length (lib.unique macs) == lib.length macs;
        message = ''
          Two or more devices have the same MAC address specified!
          This should never be possible, please check your configuration.
        '';
        # TODO: print MACs or hostnames to easily identify duplicates
        #   use the following one-liner for now:
        #   nix eval .\#nixosConfigurations.gaia.config.devices --raw --apply 'devices: let macs = (map (d: d.mac) (builtins.filter (d: d.mac != null && d.local) (builtins.attrValues devices))); in builtins.concatStringsSep "\n" macs' | sort | uniq -cD
      }
      {
        assertion =
          let
            localIPs = map (d: d.ip) (builtins.filter (d: d.local && d.ip != null) (builtins.attrValues cfg));
          in
          lib.length (lib.unique localIPs) == lib.length localIPs;
        message = ''
          Two or more local devices have the same IP address specified!
          This should never be a good idea, please check your configuration.
        '';
        # TODO: same as above
      }
    ];
  };
}
