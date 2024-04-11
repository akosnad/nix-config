{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;

  useBuilder = { hostname, user ? "root", port ? "22" }: {
    machineConfig = {
      hostName = "${hostname}-builder";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      sshUser = user;
      sshKey = builderKey;
    };
    sshConfig = ''
      Host ${hostname}-builder
        HostName ${hostname}
        User ${user}
        Port ${port}
        IdentityFile ${builderKey}
        IdentitiesOnly yes
    '';
  };

  kratos = useBuilder { hostname = "kratos"; };
in
{
  nix.distributedBuilds = true;
  nix.buildMachines = [ kratos.machineConfig ];

  programs.ssh.extraConfig = builtins.concatStringsSep "\n" [
    kratos.sshConfig
  ];

  sops.secrets.builder-common-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
