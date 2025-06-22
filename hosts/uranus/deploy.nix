{ config, ... }:
let
  ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.deploy = {
    isSystemUser = true;
    useDefaultShell = true; # allow login
    group = "deploy";
    extraGroups = ifGroupExists [
      "network"
      "docker"
      "podman"
      "libvirtd"
    ];
    openssh.authorizedKeys.keyFiles = [ ./deploy.pub ];
  };
  users.groups.deploy = { };
  nix.settings.trusted-users = [ "deploy" ];
}
