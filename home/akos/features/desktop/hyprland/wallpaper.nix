{ config, ... }:
let
  hasWallpaper = ! (builtins.isNull config.wallpaper);
in
{
  services.hyprpaper = {
    enable = hasWallpaper;
    settings = {
      preload = [ config.wallpaper ];
      # TODO: support multiple wallpapers per monitor
      wallpaper = builtins.map (monitor: "${monitor.name},${config.wallpaper}") config.monitors;
    };
  };
}
