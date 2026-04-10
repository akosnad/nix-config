{ lib, config, ... }:
{
  config.flake.modules.nixos."hosts/gaia" = {
    imports =
      with config.flake.modules.nixos;
      [
        # profiles
        base
        akos
        server

        # services
        postgres
        use-builders
        home-assistant
      ]
      ++ [
        {
          home-manager.users.akos = {
            imports = with config.flake.modules.homeManager; [
              # profiles
              base
              akos
            ];

            home.persistence = lib.mkForce { };
          };
        }
      ];

    systemd.machineId = "56f84fe4f56849a19b57bb1336ebc4f3";

    environment.persistence."/persist".enable = lib.mkForce false;

    # required by home assistant bluetooth integration
    # reference: https://www.home-assistant.io/integrations/bluetooth/#requirements-for-linux-systems
    services.dbus.implementation = "broker";

    system.stateVersion = "24.05";
  };
}
