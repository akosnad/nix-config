{ pkgs, ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      normal_window = true;
      allow_images = true;
      image_size = 24;
      insensitive = true;
      style = pkgs.writeText "wofi-style.css" /* css */ ''
        #img {
          padding-right: 10px;
        }
      '';
    };
  };
}
