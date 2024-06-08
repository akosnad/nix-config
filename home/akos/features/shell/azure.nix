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
}
