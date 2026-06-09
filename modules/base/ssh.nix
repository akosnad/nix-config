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
        settings = {
          "Host ${builtins.concatStringsSep " " hostNames}" = {
            ForwardAgent = true;
            RemoteForward = [
              {
                bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
                host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
              }
              {
                bind.address = ''/%d/.waypipe/server.sock'';
                host.address = ''/%d/.waypipe/client.sock'';
              }
            ];
            SetEnv.WAYLAND_DISPLAY = "wayland-waypipe";
            StreamLocalBindUnlink = "yes";
          };
          "Host *" = {
            ForwardAgent = false;
            AddKeysToAgent = "no";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          };
        };
      };

      home.persistence."/persist".files = [ ".ssh/known_hosts" ];
    };
}
