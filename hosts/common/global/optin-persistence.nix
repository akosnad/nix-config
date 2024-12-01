{ inputs, lib, config, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];

      files = [
        "/etc/machine-id"

        # for system auto upgrading to remember trusted settings in flake
        "/root/.local/share/nix/trusted-settings.json"
      ];
    };
  };

  # since /etc/machine-id is mounted from /persist, not a temporary file system,
  # we need to disable the systemd service that writes it to prevent it from failing
  # reference: https://www.freedesktop.org/software/systemd/man/256/systemd-machine-id-commit.service.html
  systemd.services.systemd-machine-id-commit = {
    enable = false;
  };

  programs.fuse.userAllowOther = true;

  system.activationScripts.persistent-dirs.text =
    let
      mkHomePersist = user:
        lib.optionalString user.createHome /* bash */ ''
          mkdir -p /persist/${user.home}
          chown ${user.name}:${user.group} /persist/${user.home}
          chmod ${user.homeMode} /persist/${user.home}
        '';
      users = lib.attrValues config.users.users;
    in
    lib.concatLines (map mkHomePersist users);
}
