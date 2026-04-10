{ config, lib, ... }:
{
  flake.devices.kratos = {
    info = "Ryzen 3600X, 32GB RAM, Radeon 7800XT";
    mac = "A8:5E:45:CD:FC:8A";
    ip = "10.2.0.1";
  };

  flake.modules.nixos."hosts/kratos" = { pkgs, ... }: {
    imports =
      with config.flake.modules.nixos;
      [
        # profiles
        base
        akos
        builder
        desktop
        dev

        # boot
        secureboot
        ephemeral-btrfs

        # services
        docker
        waydroid
        virt-manager
        nix-cache-proxy
        iscsi-initiator
      ]
      ++ [
        {
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
              linphone
              waydroid
            ];
          };
        }
      ];

    networking.hostName = "kratos";
    systemd.machineId = "8b307f92eee5d0ac8c672792c8239662";

    networking.networkmanager.enable = true;

    programs.nh.clean.enable = false;

    services.envfs.enable = true;

    sops.secrets.restic-persist-password.sopsFile = ./secrets.yaml;

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/equilibrium-gray-dark.yaml";
    specialisation.light.configuration.stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/equilibrium-gray-light.yaml";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  };
}
