{ lib, inputs, config, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    "docker"
    "libvirt"
  ];
}
