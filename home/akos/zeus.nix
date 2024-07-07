{ lib, inputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    ./global
  ];

  # disable impermanence for now
  home.persistence = lib.mkForce { };
}
