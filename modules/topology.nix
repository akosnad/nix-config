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
        services.forwardedPorts = lib.mkIf (lib.length d.forwardedPorts > 0) {
          name = "Forwarded ports";
          icon = "services.nat";
          details =
            let
              filterProtocol = proto: builtins.filter (p: builtins.elem p.proto [ proto "tcpudp" ]);
              formatPorts = map (p: if p.source == p.dest then toString p.dest else "${toString p.dest}:${toString p.source}");
              mkPortForwardList = proto: lib.pipe d.forwardedPorts [
                (filterProtocol proto)
                formatPorts
              ];

              tcpPorts = mkPortForwardList "tcp";
              udpPorts = mkPortForwardList "udp";
            in
            {
              tcp = lib.mkIf (lib.length tcpPorts > 0) { text = lib.concatStringsSep " " tcpPorts; };
              udp = lib.mkIf (lib.length udpPorts > 0) { text = lib.concatStringsSep " " udpPorts; };
            };
        };
        services.blockInternetAccess = lib.mkIf (builtins.elem true (lib.attrValues d.blockInternetAccess)) {
          name = "Internet access blocked";
          icon = "services.block-internet";
          details = {
            methods.text = lib.pipe d.blockInternetAccess [
              (lib.filterAttrs (_: v: v))
              lib.attrNames
              (lib.concatStringsSep " ")
            ];
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
