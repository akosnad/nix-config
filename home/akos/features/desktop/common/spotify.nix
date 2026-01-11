{
  programs.spicetify = {
    enable = true;
  };

  home.persistence."/persist".directories = [
    ".config/spotify"
    ".cache/spotify"
  ];
}
