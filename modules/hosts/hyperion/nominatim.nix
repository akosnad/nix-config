{
  flake.modules.nixos."hosts/hyperion" = {
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

        NOMINATIM_REPLICATION_URL = "https://planet.openstreetmap.org/replication/minute";
        NOMINATIM_REPLICATION_MAX_DIFF = "100";
      };
      ui.config = /* js */ ''
        Nominatim_Config.Page_Title='nominatim.home.arpa';
        Nominatim_Config.Nominatim_API_Endpoint='https://nominatim.home.arpa/';
      '';
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
  };
}
