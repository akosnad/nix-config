{ outputs, config, lib, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;

  hasOptinPersistence = if config.environment.persistence ? "/persist" then config.environment.persistence."/persist".enable else false;
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

    hostKeys = [{
      path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  programs.ssh = {
    knownHosts = builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          lib.optional (name == hostName) "localhost";
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
}
