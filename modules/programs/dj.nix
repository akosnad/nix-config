{
  flake.modules.homeManager.dj = { pkgs, ... }: {
    home.packages = [ pkgs.mixxx ];

    home.persistence."/persist".directories = [
      ".mixxx"
    ];
  };
}
