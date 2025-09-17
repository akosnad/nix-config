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
      "dialout"
    ] ++ ifGroupExists [
      "network"
      "wireshark"
      "docker"
      "podman"
      "libvirtd"
      "plugdev"
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../../../home/akos/ssh.pub)
    ];
    hashedPasswordFile = config.sops.secrets.akos-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets = {
    akos-password = {
      sopsFile = ../../secrets.yaml;
      neededForUsers = true;
    };
  };

  home-manager.users.akos = import ../../../../home/akos/${config.networking.hostName}.nix;

  security.pam.services.hyprlock = {
    name = "hyprlock";
    u2fAuth = true;
    unixAuth = false;
  };

  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings = {
      debug = false;
      origin = "pam://akosnad-nixos-common";
      appid = "pam://akosnad-nixos-common";
      authfile = config.sops.secrets.u2f-mappings.path;
    };
  };
  sops.secrets.u2f-mappings = {
    sopsFile = ../../secrets.yaml;
    mode = "444";
  };

  # security.pam.yubico = {
  #   enable = true;
  #   debug = false;
  #   id = "102521";
  #   mode = "client";
  #   control = "sufficient";
  # };
}
