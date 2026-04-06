{ lib, config, ... }:
let
  hosts = config.flake.nixosConfigurations;
in
{
  flake.modules.nixos.base =
    { config, ... }:
    let
      inherit (config.networking) hostName;
      pubKey = host: ../hosts/${host}/ssh_host_ed25519_key.pub;

      hasOptinPersistence =
        if config.environment.persistence ? "/persist" then
          config.environment.persistence."/persist".enable
        else
          false;
    in

    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          # Automatically remove stale sockets
          StreamLocalBindUnlink = "yes";
          # Allow forwarding ports anywhere
          GatewayPorts = "clientspecified";
        };

        hostKeys = [
          {
            path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };

      programs.ssh = {
        knownHosts = builtins.mapAttrs
          (name: _: {
            publicKeyFile = pubKey name;
            extraHostNames = lib.optional (name == hostName) "localhost";
          })
          hosts;
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Passwordless sudo when SSH'ing with keys
      security.pam.sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
      };

      # Keep SSH_AUTH_SOCK when using sudo
      security.sudo.extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';
    };

  flake.modules.homeManager.base =
    let
      hostNames = builtins.attrNames hosts;
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
          net = {
            host = builtins.concatStringsSep " " hostNames;
            forwardAgent = true;
            remoteForwards = [
              {
                bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
                host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
              }
              {
                bind.address = ''/%d/.waypipe/server.sock'';
                host.address = ''/%d/.waypipe/client.sock'';
              }
            ];
            setEnv.WAYLAND_DISPLAY = "wayland-waypipe";
            extraOptions.StreamLocalBindUnlink = "yes";
          };
        };
      };

      home.persistence."/persist".files = [ ".ssh/known_hosts" ];
    };
}
