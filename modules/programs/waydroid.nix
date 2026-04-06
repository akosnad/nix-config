{
  config.flake.modules.nixos.waydroid = {
    virtualisation.waydroid.enable = true;

    environment.persistence."/persist".directories = [{
      directory = "/var/lib/waydroid";
      mode = "755";
    }];
  };

  config.flake.modules.homeManager.waydroid = {
    # TODO: set up android declaratively

    home.persistence."/persist".directories = [
      ".local/share/waydroid"
    ];
  };
}
