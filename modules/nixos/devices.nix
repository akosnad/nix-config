{ lib, ... }:
let
  inherit (lib) types;

  forwardedPortModule = { config, ... }: {
    options = {
      dest = lib.mkOption {
        description = "Destination port on the host that will be forwarded.";
        type = types.int;
      };
      source = lib.mkOption {
        description = ''
          Source port on the default gateway.

          Defaults to the destination port.
        '';
        type = types.int;
        default = config.dest;
      };
      proto = lib.mkOption {
        type = types.enum [ "tcp" "udp" "tcpudp" ];
        description = "Protocol to forward port for. Either TCP, UDP or both. Defaults to both.";
        default = "tcpudp";
      };
    };
  };

  deviceModule = { name, ... }: {
    options = {
      hostname = lib.mkOption {
        type = types.str;
        default = name;
        description = ''
          Hostname of the device on the local network.

          Defaults to attribute name.
        '';
      };
      ip = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "192.168.100.100";
        description = "Static IP address on the local network";
      };
      mac = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "00:11:22:33:44:55";
        description = "MAC address of the given device on the local network";
      };
      local = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether the device is local to the network";
      };
      extraHostnames = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional hostnames to set for the device";
      };
      forwardedPorts = lib.mkOption {
        description = ''
          List of ports that will be forwarded through the default gateway

          Applies only if the device is local.
        '';
        example = [
          8080
          { dest = 1000; source = 32000; proto = "udp"; }
          { dest = 5050; proto = "tcp"; }
        ];
        default = [ ];
        type = types.listOf (types.either types.int (types.submodule forwardedPortModule));
        apply =
          let
            transform = x: if lib.isInt x then { dest = x; source = x; proto = "tcpudp"; } else x;
          in
          list: map transform list;
      };
    };
  };
in
{
  options = {
    devices = lib.mkOption {
      default = null;
      description = ''
        Attributes of devices that get referenced throughout various configurations or present on the local network.
      '';
      type = types.nullOr (types.attrsOf (types.submodule deviceModule));
    };
  };
}
