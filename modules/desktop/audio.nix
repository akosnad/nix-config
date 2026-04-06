{
  config.flake.modules.homeManager.desktop = { pkgs, ... }: {
    home.packages = with pkgs; [ pavucontrol ];

    home.persistence."/persist".directories = [ ".local/state/wireplumber" ];
  };
}
