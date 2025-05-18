{ config, lib, ... }:
let
  inherit (lib) mkIf attrNames concatStringsSep filterAttrs hasAttr mapAttrs;

  frigateCameras = config.services.frigate.settings.cameras;
in
{
  config.topology.self.services = mkIf config.topology.extractors.services.enable {
    buildbot = mkIf config.services.buildbot-master.enable {
      name = "Buildbot";
      icon = "services.buildbot";
      details = {
        url.text = config.services.buildbot-master.buildbotUrl;
      };
    };

    frigate = mkIf config.services.frigate.enable {
      name = "Frigate";
      icon = "services.frigate";
      details = {
        cameras.text = concatStringsSep " " (attrNames frigateCameras);
      };
    };

    go2rtc = mkIf config.services.go2rtc.enable {
      name = "go2rtc";
      icon = "services.go2rtc";
      details =
        let
          cfg = config.services.go2rtc;
        in
        {
          rtsp.text = cfg.settings.rtsp.listen;
          streams.text = concatStringsSep " " (attrNames cfg.settings.streams);
        };
    };

    asterisk = mkIf config.services.asterisk.enable {
      name = "Asterisk";
      icon = "services.asterisk";
    };

    harmonia = mkIf config.services.harmonia.enable {
      name = "Harmonia";
      icon = "services.harmonia";
      details =
        let
          cfg = config.services.harmonia;
        in
        {
          bind.text = cfg.settings.bind;
          priority.text = toString cfg.settings.priority;
        };
    };

    step-ca = mkIf config.services.step-ca.enable {
      name = "Step CA";
      icon = "services.smallstep";
      details =
        let
          cfg = config.services.step-ca;
        in
        {
          listen.text = "${cfg.address}:${toString cfg.port}";
          provisioners.text = concatStringsSep " " (map (p: p.name) cfg.settings.authority.provisioners);
        };
    };

    matrix-synapse = mkIf config.services.matrix-synapse.enable {
      name = "Matrix Synapse";
      icon = "services.matrix";
      info = config.services.matrix-synapse.settings.server_name;
      details =
        let
          cfg = config.services.matrix-synapse;
        in
        {
          url.text = cfg.settings.public_baseurl;
        };
    };
  };

  # give nodes a camera icon that are referenced in frigate
  config.topology.nodes =
    let
      cameraDevices = filterAttrs (node: _: hasAttr node frigateCameras) config.devices;
      apply = _node: _value: {
        icon = lib.mkDefault "devices.camera";
      };
    in
    mkIf config.services.frigate.enable (mapAttrs apply cameraDevices);
}
