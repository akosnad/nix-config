{
  flake.modules.nixos."hosts/hyperion" = _: {
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
  };
}
