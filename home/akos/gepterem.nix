{ lib, ... }:
{
  imports = [
    ./global
  ];

  home.username = lib.mkForce "nadak";

}
