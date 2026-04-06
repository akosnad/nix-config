{ lib, config, ... }:
let
  flakeConfig = config;
in
{
  config.flake.modules.nixos."hosts/work-laptop" =
    { config, ... }:
    {
      imports = with flakeConfig.flake.modules.nixos; [
        # profiles
        base
        akos
      ] ++ [{
        home-manager.users.akos = {
          imports = with flakeConfig.flake.modules.homeManager; [
            # profiles
            base
            akos

            # services
            vscode-server
            waypipe

            # programs
            helix-lsp
            gh
          ];

          home.persistence = lib.mkForce { };
          services.gpg-agent.enable = lib.mkForce false;
          programs.gpg.enable = lib.mkForce false;
        };
      }];

      systemd.machineId = "cefd72516b8649419ff6ebe55535d17f";
      environment.persistence."/persist".enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;

      wsl = {
        enable = true;
        defaultUser = "akos";
        wslConf.automount.options = "metadata,uid=${toString config.users.users.akos.uid},gid=${toString config.users.groups.users.gid},umask=002,dmask=002,fmask=002";
      };
      networking.hostName = "work-laptop";
      networking.firewall.enable = false;
      nixpkgs.hostPlatform = "x86_64-linux";

      topology.self = {
        icon = "devices.wsl";
        hardware.info = "ThinkPad P14s Gen 5";
        interfaces.wifi.physicalConnections = [
          {
            node = "internet";
            interface = "*";
            renderer.reverse = true;
          }
        ];
      };

      system.stateVersion = "25.05";
    };
}
