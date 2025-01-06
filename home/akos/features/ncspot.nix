{ config, ... }:
{
  programs.ncspot = {
    enable = true;
    settings = {
      use_nerdfont = true;
      volnorm = true;
      bitrate = 320;
      library_tabs = [
        "tracks"
        "playlists"
        "browse"
        "albums"
        "artists"
      ];
      credentials = {
        username_cmd = "cat ${config.sops.secrets.spotify-username.path}";
        password_cmd = "cat ${config.sops.secrets.spotify-password.path}";
      };
    };
  };

  sops.secrets = {
    spotify-username = { };
    spotify-password = { };
  };
}
