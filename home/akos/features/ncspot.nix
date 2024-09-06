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
        username_cmd = "cat /run/secrets/spotify-username";
        password_cmd = "cat /run/secrets/spotify-password";
      };
    };
  };
}
