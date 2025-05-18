{ config, lib, ... }:
let
  inherit (lib) mkIf attrNames concatStringsSep hasAttr
    mapAttrs mapAttrs' mkEnableOption flip nameValuePair head tail length;

  cfg = config.virtualisation.arion;
in
{
  options.topology.extractors.arion.enable = mkEnableOption "topology arion extractor" // { default = true; };

  config = mkIf (config.topology.extractors.arion.enable && hasAttr "arion" config.virtualisation) {
    topology.nodes = flip mapAttrs' cfg.projects (name: c: nameValuePair "arion-${name}" {
      inherit name;
      deviceType = "arion";
      guestType = "docker-compose (arion)";
      icon = "services.docker";
      deviceIcon = "services.hercules-ci";
      parent = config.topology.self.id;

      interfaces = flip mapAttrs c.settings.networks (name: _v: (if name == "default" then {
        physicalConnections = [{ node = config.topology.self.id; interface = "docker"; renderer.reverse = true; }];
      } else {
        physicalConnections =
          let
            nameParts = lib.match "^(.*)_(.*)$" name; # what a cool regex-oticon! :)
            # FIXME: this should check for v.external instead of guessing based on the presence
            # of the character `_`. we can't check for v.external, because arion does not set
            # a default value, thus we get an eval error even if "hasAttr"ing it.
            #
            # either we should set the default to false, or ... ?
          in
          mkIf (if nameParts != null then length nameParts > 1 else false) [{
            node = "arion-${head nameParts}";
            interface = toString (tail nameParts);
          }];
      }) // {
        icon = "interfaces.tun";
      });

      services = flip mapAttrs c.settings.services (n: v: {
        name = if v.service.container_name != null then v.service.container_name else n;
        info = v.service.image;
        icon = "services.${n}";
        details = let cfg = v.service; in {
          ports = mkIf (cfg.ports != [ ]) { text = concatStringsSep " " cfg.ports; };
          volumes = mkIf (cfg.volumes != [ ]) { text = concatStringsSep " " cfg.volumes; };
        };
      });
    });

    topology.self.interfaces = mkIf (length (attrNames config.virtualisation.arion.projects) > 0) {
      docker = {
        icon = "interfaces.tun";
      };
    };
  };
}
