{ config, pkgs, ... }:
let
  ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.akos = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ] ++ ifGroupExists [
      "network"
      "wireshark"
      "docker"
    ];
    hashedPasswordFile = config.sops.secrets.akos-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.akos-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.akos = import ../../../../home/akos/${config.networking.hostName}.nix;
}
