{
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  home.persistence."/persist".directories = [
    ".config/kdeconnect"
  ];
}
