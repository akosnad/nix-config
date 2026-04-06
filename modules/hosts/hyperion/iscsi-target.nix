{
  config.flake.modules.nixos."hosts/hyperion" =
    { config, ... }:
    let
      default_portal = {
        ip_address = "[::0]";
        iser = false;
        offload = false;
        port = 3260;
      };

      mkTarget =
        { name
        , nodes
        , storageObject
        ,
        }:
        {
          fabric = "iscsi";
          tpgs = [
            {
              attributes = {
                authentication = 0;
              };
              enable = true;
              luns = [
                {
                  index = 0;
                  storage_object = storageObject;
                }
              ];
              node_acls = map
                (nodeName: {
                  mapped_luns = [
                    {
                      index = 0;
                      tpg_lun = 0;
                      write_protect = false;
                    }
                  ];
                  node_wwn = "iqn.2003-01.${nodeName}.${config.networking.domain}";
                })
                nodes;
              portals = [ default_portal ];
              tag = 1;
            }
          ];
          wwn = "iqn.2003-01.${config.networking.fqdn}:${name}";
        };
    in
    {
      services.target = {
        enable = true;
        config = {
          storage_objects = [
            {
              dev = "/dev/disk/by-id/ata-Optiarc_DVD_RW_AD-7200S";
              name = "optical";
              plugin = "pscsi";
            }
            {
              dev = "/dev/zvol/thesauros/win-iscsi";
              name = "win";
              plugin = "block";
              alua_tpgs = [{ name = "default_tg_pt_gp"; }];
            }
          ];
          targets = map mkTarget [
            {
              name = "optical";
              nodes = [ "kratos" ];
              storageObject = "/backstores/pscsi/optical";
            }
            {
              name = "win";
              nodes = [ "kratos" ];
              storageObject = "/backstores/block/win";
            }
          ];
        };
      };

      networking.firewall.allowedTCPPorts = [ default_portal.port ];
    };
}
