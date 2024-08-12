{ config, ... }:
{
  imports = [
    ./global
  ];

  home.file."test.txt".text = "hello";
  home.sessionVariables = {
    FOO = "BAR";
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    "docker"
    "libvirt"
    "ca"
  ];
}
