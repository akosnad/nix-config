{
  config.flake.modules.nixos.home-assistant =
    { pkgs, ... }:
    {
      services.home-assistant = {
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
          mushroom
          mini-media-player
          plotly-graph-card
          wallpanel
          webrtc-camera
          card-mod
        ];

        # sets the mode for default dashboard
        config.lovelace.resource_mode = "yaml";
      };
    };
}
