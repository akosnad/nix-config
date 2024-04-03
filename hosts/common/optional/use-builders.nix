{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;

  useBuilder = { hostname, user, port ? "22" }: {
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

  kratos = useBuilder { hostname = "kratos"; user = "root"; port = "2022"; };
in
{
  nix.distributedBuilds = true;
  nix.buildMachines = [ kratos.machineConfig ];

  programs.ssh.extraConfig = builtins.concatStringsSep "\n" [
    kratos.sshConfig
  ];

  networking.hosts = {
    "10.0.0.3" = [ "kratos" ];
  };

  sops.secrets.builder-common-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
