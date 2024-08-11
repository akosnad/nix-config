{ pkgs, ... }:
{
  imports = [
    ./akos.nix
  ];

  services.home-assistant = {
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      mini-media-player
      plotly-graph-card
      wallpanel
    ];

    # sets the mode for default dashboard
    config.lovelace.mode = "yaml";

    # default dashboard (Overview)
    lovelaceConfig = {
      title = "Test";
      views = [{
        title = "test";
        cards = [{
          type = "custom:plotly-graph";
          entities = [{ entity = "sun.sun"; }];
          hours_to_show = 24;
          refresh_interval = 10;
        }];
      }];
    };
  };
}
