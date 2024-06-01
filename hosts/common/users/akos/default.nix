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
      "libvirtd"
    ];

    openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/akos/ssh.pub) ];
    hashedPasswordFile = config.sops.secrets.akos-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets = {
    akos-password = {
      sopsFile = ../../secrets.yaml;
      neededForUsers = true;
    };
    cachix-auth-token = {
      sopsFile = ../../secrets.yaml;
      owner = "akos";
    };
  };

  home-manager.users.akos = import ../../../../home/akos/${config.networking.hostName}.nix;

  # this fixes swaylock not accepting any password
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
}
