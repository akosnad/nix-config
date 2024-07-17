{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;

  useBuilder = { hostname, user ? "root", port ? "22", speedFactor ? 1, supportedFeatures ? [ ], systems ? [ ] }: {
    machineConfig = {
      inherit speedFactor supportedFeatures systems;
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

  kratos = useBuilder { hostname = "kratos"; speedFactor = 3; supportedFeatures = [ "big-parallel" "kvm" ]; systems = [ "x86_64-linux" "aarch64-linux" ]; };
  zeus = useBuilder { hostname = "zeus"; supportedFeatures = [ "big-parallel" "kvm" ]; systems = [ "x86_64-linux" "aarch64-linux" ]; };
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
