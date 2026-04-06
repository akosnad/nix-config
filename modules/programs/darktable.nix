{
  config.flake.modules.homeManager.darktable =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        darktable
      ];

      home.persistence."/persist".directories = [
        ".config/darktable"
      ];
    };
}
