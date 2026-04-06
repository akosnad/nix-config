{
  flake.modules.nixos.akos =
    { pkgs, config, ... }:
    let
      gpgKey = pkgs.callPackage ./_gpg-key.nix { inherit pkgs; };
      ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
    in
    {
      users.users.akos = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "video"
          "audio"
          "dialout"
        ]
        ++ ifGroupExists [
          "network"
          "wireshark"
          "docker"
          "podman"
          "libvirtd"
          "plugdev"
        ];

        openssh.authorizedKeys.keyFiles = [ "${gpgKey}/ssh.pub" ];
        hashedPasswordFile = config.sops.secrets.akos-password.path;
      };

      sops.secrets = {
        akos-password = {
          neededForUsers = true;
        };
      };

    };

  flake.modules.homeManager.akos = { config, ... }: {
    programs.home-manager.enable = true;
    home.stateVersion = "23.11";

    home.file.".yubico/authorized_yubikeys".text = "${config.home.username}:cccccbkcfrgn";

    sops.sopsFile = ./secrets.yaml;
  };
}
