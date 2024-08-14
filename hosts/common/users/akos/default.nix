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
    gh-auth-token = {
      sopsFile = ../../secrets.yaml;
      owner = "akos";
    };
  };

  home-manager.users.akos = import ../../../../home/akos/${config.networking.hostName}.nix;
  home-manager.extraSpecialArgs = {
    inherit (config.networking) hostName;
  };

  # this fixes swaylock not accepting any password
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  security.pam.services.hyprlock = {
    text = ''
      auth include login
    '';
  };

  security.pam.u2f = {
    enable = true;
    debug = false;
    origin = "pam://akosnad-nixos-common";
    appId = "pam://akosnad-nixos-common";
    control = "sufficient";
    authFile = config.sops.secrets.u2f-mappings.path;
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
