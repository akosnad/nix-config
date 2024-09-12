{ lib, ... }:
{
  imports = [
    ./global
  ];

  home.username = lib.mkForce "nadak";
  home.persistence = lib.mkForce { };
}
