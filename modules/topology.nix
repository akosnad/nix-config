outputs: { lib, ... }: {
  nodes =
    let
      localDevices = lib.filterAttrs (_n: d: d.local && !d.hidden) outputs.devices;
      hasEspHome = name: lib.hasAttr name outputs.esphomeConfigurations;
    in
    lib.mapAttrs
      (n: d: {
        name = lib.mkDefault d.name;
        deviceType = lib.mkDefault "device";
        deviceIcon = lib.mkIf (hasEspHome n) "devices.esphome";
        hardware.info = lib.mkIf (d.info != null) d.info;
        interfaces = lib.mkIf (d.ip != null) {
          "${if d.connectionMedium == "wifi" then "wifi" else "lan1"}" = {
            addresses = lib.mkForce [ d.ip ];
            network = if d.connectionMedium == "wifi" then "gaia-wifi" else "gaia";
            physicalConnections = lib.mkIf (d.connectionMedium == "wifi") [{
              node = "gaia-wifi";
              interface = "*";
              renderer.reverse = lib.mkDefault true;
            }];
          };
        };
      })
      localDevices;

  icons =
    let
      iconsBasePath = ../assets/icons;
      stripFileExtension = x:
        let
          base = builtins.match "^(.*)\\.[^./]*$" x;
        in
        if base != null then builtins.head base else x;
      mkCategory = category: lib.pipe (builtins.readDir "${iconsBasePath}/${category}") [
        (lib.filterAttrs (_: v: v != "directory"))
        (lib.mapAttrs' (k: _: lib.nameValuePair (stripFileExtension k) { file = "${iconsBasePath}/${category}/${k}"; }))
      ];
    in
    lib.pipe (builtins.readDir iconsBasePath) [
      (lib.filterAttrs (_: v: v == "directory")) # attrset of categories
      (lib.mapAttrs (k: _: mkCategory k)) # <category>.<icon>.file = "..."
    ];
}
