{
  flake.modules.nixos."hosts/hyperion" = {
    users.users.backup = {
      isSystemUser = true;
      useDefaultShell = true; # allow login
      group = "backup";
      openssh.authorizedKeys.keyFiles = [ ./backup.pub ];
      home = "/backup/nixos";
      createHome = true;
    };
    users.groups.backup = { };

    services.openssh.extraConfig = ''
      Match User backup
        ChrootDirectory /backup
        ForceCommand internal-sftp
        Subsystem sftp internal-sftp
        AllowTcpForwarding no
        AllowAgentForwarding no
        X11Forwarding no
        PermitTTY no
    '';

    services.webdav = {
      enable = true;
      settings = {
        address = "0.0.0.0";
        port = 8868;
        directory = "/backup";
        permissions = "RCU";
      };
    };
    networking.firewall.allowedTCPPorts = [ 8868 ];
    users.users.webdav.extraGroups = [ "backup" ];
  };
}
