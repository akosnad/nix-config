{ config, lib, ... }:
{
  flake.modules.nixos."hosts/athena" = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      # profiles
      base
      akos
      desktop
      dev
      powersave
      wifi
      bluetooth
      use-builders

      # boot
      secureboot
      ephemeral-btrfs

      # services
      docker
      nix-cache-proxy
    ] ++ [{
      home-manager.users.akos = {
        imports = with config.flake.modules.homeManager; [
          # profiles
          base
          akos
          desktop
          dev

          # programs
          darktable
          iamb
        ];
      };
    }];

    networking.hostName = "athena";
    systemd.machineId = "c6b3a9565956fc03b91bb71e36655eb3";
    networking.networkmanager.enable = true;

    systemd.services.docker = {
      enable = true;
      # Only start docker when the socket is first accessed
      wantedBy = lib.mkForce [ ];
    };

    programs.nh.clean.enable = false;

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-dark.yaml";
    specialisation.light.configuration.stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/selenized-light.yaml";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  };
}
