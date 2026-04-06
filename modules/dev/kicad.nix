let
  flake.modules.homeManager.kicad =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ kicad ];

      home.persistence."/persist".directories = [
        ".cache/kicad"
        ".local/share/kicad"
        ".config/kicad"
      ];
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.kicad ];
in
{
  inherit flake;
}
