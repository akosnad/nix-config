{ config, ... }:
let
  fontFamily = config.fontProfiles.monospace.family;
in
{
  imports = [
    ./theme.nix
  ];

  programs.kitty = {
    enable = true;
    font.name = fontFamily;
    settings = {
      background_opacity = "0.9";
      enable_audio_bell = false;
      update_check_interval = 0;
      window_padding_width = 8;
    };
  };
}
