{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;

  useBuilder = { hostname, user ? "root", port ? "22", speedFactor ? 1 }: {
    machineConfig = {
      hostName = "${hostname}-builder";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      sshUser = user;
      sshKey = builderKey;
      speedFactor = speedFactor;
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

  kratos = useBuilder { hostname = "kratos"; speedFactor = 3; };
  zeus = useBuilder { hostname = "zeus"; };
in
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    kratos.machineConfig
    zeus.machineConfig
  ];

  programs.ssh.extraConfig = builtins.concatStringsSep "\n" [
    kratos.sshConfig
    zeus.sshConfig
  ];

  sops.secrets.builder-common-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
