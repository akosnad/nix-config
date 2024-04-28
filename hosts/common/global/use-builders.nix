{ config, ... }:
let
  builderKey = config.sops.secrets.builder-common-key.path;
  inherit (config.networking) hostName;

  useBuilder = { hostname, user ? "root", port ? "22", speedFactor ? 1, supportedFeatures? [] }: {
    machineConfig = {
      hostName = "${hostname}-builder";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      sshUser = user;
      sshKey = builderKey;
      speedFactor = speedFactor;
      supportedFeatures = supportedFeatures;
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

  machines = [
    { hostname = "kratos"; speedFactor = 3; supportedFeatures = [ "big-parallel" "kvm" ]; }
    { hostname = "zeus"; supportedFeatures = [ "big-parallel" "kvm" ]; }
  ];

  filteredMachines = builtins.filter (m: m.hostname != hostName) machines;
  builders = builtins.map (m: useBuilder m) filteredMachines;

  buildMachines = builtins.map (m: m.machineConfig) builders;
  sshConfigs = builtins.map (m: m.sshConfig) builders;

in
{
  nix.distributedBuilds = true;
  nix.buildMachines = buildMachines;

  programs.ssh.extraConfig = builtins.concatStringsSep "\n" (sshConfigs);

  sops.secrets.builder-common-key = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
