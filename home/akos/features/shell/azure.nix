{ pkgs, config, ... }:
let
  extensions = with pkgs.azure-cli-extensions; [
    webapp
  ];
in
{
  home.packages = [
    (pkgs.azure-cli.withExtensions extensions)
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [ ".azure" ];
}
