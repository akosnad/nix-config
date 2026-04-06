{
  config.flake.modules.homeManager.desktop = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    home.persistence."/persist".directories = [
      ".config/kdeconnect"
    ];
  };

  config.flake.modules.nixos.desktop = {
    # needed to open for firewall
    programs.kdeconnect.enable = true;
  };
}
