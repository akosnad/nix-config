{
  config.flake.modules.nixos.waydroid = { pkgs, ... }: {
    virtualisation.waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
    networking.nftables.enable = true;

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
