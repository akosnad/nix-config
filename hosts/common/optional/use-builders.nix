{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;

  useBuilder = { hostname, user ? "root", port ? "22", speedFactor ? 1, supportedFeatures ? [ ], systems ? [ "x86_64-linux" ] }: {
    machineConfig = {
      inherit speedFactor supportedFeatures systems;
      hostName = "${hostname}-builder";
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
        ConnectTimeout 3
        IdentityFile ${builderKey}
        IdentitiesOnly yes
    '';
    inherit hostname;
  };

  kratos = useBuilder {
    hostname = "kratos";
    speedFactor = 3;
    supportedFeatures = [ "big-parallel" "kvm" ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
  };
  hyperion = useBuilder {
    hostname = "hyperion";
    supportedFeatures = [ "big-parallel" "kvm" ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
  };

  machines =
    builtins.filter (m: config.networking.hostName != m.hostname) [ kratos hyperion ];

  substituters = map (machine: "ssh-ng://root@${machine.hostname}-builder") machines;
in
{
  nix = {
    distributedBuilds = true;
    buildMachines = map (machine: machine.machineConfig) machines;
    settings = {
      inherit substituters;
      trusted-substituters = substituters;
    };
  };

  programs.ssh.extraConfig = builtins.concatStringsSep "\n" (map (machine: machine.sshConfig) machines);

  sops.secrets.builder-common-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
