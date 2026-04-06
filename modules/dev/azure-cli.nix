let
  flake.modules.homeManager.azure-cli =
    { pkgs, ... }:
    let
      extensions = with pkgs.azure-cli-extensions; [
        webapp
      ];
    in
    {
      home.packages = [
        (pkgs.azure-cli.withExtensions extensions)
      ];

      home.persistence."/persist".directories = [ ".azure" ];
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.azure-cli ];
in
{
  inherit flake;
}
