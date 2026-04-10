{ inputs, lib, ... }:
{
  config.flake.modules.nixos.buildbot-master = { config, ... }:
    let
      domain = "buildbot.fzt.one";
      masterSecretNames = map (s: "buildbot-${s}") [
        "github-app-key"
        "github-ssh-key"
        "webhook-secret"
        "github-oauth-secret"
        "workers"
        "uranus-deploy-key"
      ];
      buildbotSecrets = lib.genAttrs masterSecretNames (_n: { sopsFile = ./secrets.yaml; });

      secretsCfg = config.sops.secrets;
    in
    {
      imports = [
        inputs.buildbot-nix.nixosModules.buildbot-master
      ];

      services.buildbot-nix.master = {
        enable = true;
        inherit domain;
        workersFile = "${secretsCfg.buildbot-workers.path}";
        buildSystems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        admins = [ "akosnad" ];
        github = {
          topic = "buildbot-akosnad";
          appId = 960427;
          appSecretKeyFile = "${secretsCfg.buildbot-github-app-key.path}";
          webhookSecretFile = "${secretsCfg.buildbot-webhook-secret.path}";
          oauthId = "Ov23liqrF61WKdRZCwr7";
          oauthSecretFile = "${secretsCfg.buildbot-github-oauth-secret.path}";
        };
        effects.perRepoSecretFiles = {
          "github:akosnad/personal-site" = config.sops.secrets.buildbot-uranus-deploy-key.path;
        };
      };

      services.buildbot-master = {
        buildbotUrl = lib.mkForce "https://${domain}/";
        extraConfig = ''
          c["protocols"] = {"pb": {"port": "tcp:9989:interface=\\:\\:"}}
        '';
      };

      services.nginx.virtualHosts."${domain}" = {
        listen = [{ addr = "0.0.0.0"; port = 8080; ssl = false; }];
      };

      networking.firewall.allowedTCPPorts = [
        # buildbot HTTP
        8080
      ];

      sops.secrets = buildbotSecrets;

      programs.ssh.extraConfig = ''
        Host github.com
          User git
          IdentityFile ${config.sops.secrets.buildbot-github-ssh-key.path}
          IdentitiesOnly yes
      '';

      environment.persistence."/persist".directories = [
        {
          directory = "/var/lib/buildbot";
          mode = "750";
          inherit (config.services.buildbot-master) user group;
        }
      ];
    };
}
