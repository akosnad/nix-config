{ lib, ... }:
{
  flake.modules.nixos."hosts/hyperion" = { config, pkgs, ... }: {
    services.nominatim = {
      enable = true;
      hostName = "nominatim.home.arpa";
      settings = {
        NOMINATIM_TABLESPACE_SEARCH_DATA = "nominatim_data";
        NOMINATIM_TABLESPACE_SEARCH_INDEX = "nominatim_index";
        NOMINATIM_TABLESPACE_OSM_DATA = "nominatim_data";
        NOMINATIM_TABLESPACE_OSM_INDEX = "nominatim_index";
        NOMINATIM_TABLESPACE_PLACE_DATA = "nominatim_data";
        NOMINATIM_TABLESPACE_PLACE_INDEX = "nominatim_index";
        NOMINATIM_TABLESPACE_ADDRESS_DATA = "nominatim_data";
        NOMINATIM_TABLESPACE_ADDRESS_INDEX = "nominatim_index";
        NOMINATIM_TABLESPACE_AUX_DATA = "nominatim_data";
        NOMINATIM_TABLESPACE_AUX_INDEX = "nominatim_index";

        NOMINATIM_FLATNODE_FILE = "/var/lib/nominatim/flatnode/flatnode.bin";

        NOMINATIM_REPLICATION_URL = "https://download.geofabrik.de/europe/hungary-updates";
        NOMINATIM_REPLICATION_MAX_DIFF = "500";
        NOMINATIM_REPLICATION_UPDATE_INTERVAL = "86400";
        NOMINATIM_REPLICATION_RECHECK_INTERVAL = "900";
      };
      ui.config = /* js */ ''
        Nominatim_Config.Page_Title='nominatim.home.arpa';
        Nominatim_Config.Nominatim_API_Endpoint='https://nominatim.home.arpa/';
      '';
    };
    systemd.services.nominatim-updates = {
      environment = (lib.removeAttrs config.systemd.services.nominatim.environment [ "PATH" "PYTHONPATH" ]) // {
        PYTHONPATH =
          let
            extraPackages = pkgs.python3.withPackages (ps: with ps; [ pyosmium ]);
          in
          "${extraPackages}/lib/${extraPackages.passthru.libPrefix}/site-packages:" + config.systemd.services.nominatim.environment.PYTHONPATH;
      };
      script = ''${pkgs.nominatim}/bin/nominatim replication --once'';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "nominatim";
        Group = "nominatim";
        WorkingDirectory = "/var/lib/nominatim";
      };
    };
    systemd.timers.nominatim-updates = {
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnActiveSec = 30;
        OnUnitActiveSec = "1min";
        Unit = "nominatim-updates.service";
      };
    };

    services.postgresql.settings = {
      shared_buffers = "2GB";
    };
    systemd.services.postgresql.serviceConfig = {
      ReadWritePaths = [
        "/var/lib/nominatim/data"
        "/var/lib/nominatim/index"
      ];
    };
    services.postgresqlBackup.databases = [ "nominatim" ];
  };
}
