{ lib, ... }:
{
  flake.modules.nixos.renovate = { config, pkgs, ... }:
    let
      cfg = config.services.renovate;
    in
    {
      services.renovate = {
        enable = true;
        schedule = "*:0/5";
        runtimePackages = with pkgs; [ nix cargo rustc ];
        settings = {
          platform = "github";
          autodiscover = true;
          autodiscoverFilter = [ "/akosnad/.*/" ];
          autodiscoverTopics = [ "renovate-akosnad" ];
          nix.enabled = true;
        };
      };

      environment.persistence."/persist".directories = [
        {
          directory = cfg.settings.baseDir;
          user = "renovate";
          group = "renovate";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = cfg.settings.cacheDir;
          user = "renovate";
          group = "renovate";
          mode = "u=rwx,g=,o=";
        }
      ];

      systemd.services.renovate = {
        preStart = ''
          RENOVATE_TOKEN="$(${lib.getExe pkgs.github-app-installation-token} \
            --appId 1085578 \
            --installationId 58300809 \
            --privateKeyLocation $CREDENTIALS_DIRECTORY/renovate-github-app-key \
            2>/dev/null)"
          umask 077
          echo RENOVATE_TOKEN="$RENOVATE_TOKEN" > /run/renovate/renovate-env
        '';
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          RuntimeDirectory = "renovate";
          RuntimeDirectoryMode = "0750";
          EnvironmentFile = "-/run/renovate/renovate-env";
          LoadCredential = [ "renovate-github-app-key:${config.sops.secrets.renovate-github-app-key.path}" ];
        };
      };

      sops.secrets.renovate-github-app-key = {
        sopsFile = ../hosts/hyperion/secrets.yaml;
      };

      users = {
        users.renovate = {
          isSystemUser = true;
          group = "renovate";
        };
        groups.renovate = { };
      };

      services.restic.backups.persist.exclude = map (x: "/persist${x}") [ cfg.settings.baseDir cfg.settings.cacheDir ];
    };
}
