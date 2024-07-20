{ config, ... }:
{
  imports = [
    ./global
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    "docker"
    "libvirt"
    "ca"
  ];
}
