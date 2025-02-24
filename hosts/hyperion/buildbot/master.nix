{ inputs, config, lib, ... }:
let
  domain = "buildbot.fzt.one";
  masterSecretNames = map (s: "buildbot-${s}") [
    "github-app-key"
    "webhook-secret"
    "github-oauth-secret"
    "workers"
  ];
  buildbotSecrets = lib.genAttrs masterSecretNames (_n: { sopsFile = ../secrets.yaml; neededForUsers = true; });

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
      authType.app = {
        id = 960427;
        secretKeyFile = "${secretsCfg.buildbot-github-app-key.path}";
      };
      webhookSecretFile = "${secretsCfg.buildbot-webhook-secret.path}";
      oauthId = "Ov23liqrF61WKdRZCwr7";
      oauthSecretFile = "${secretsCfg.buildbot-github-oauth-secret.path}";
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

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/buildbot";
      mode = "750";
      inherit (config.services.buildbot-master) user group;
    }
    {
      directory = config.services.postgresql.dataDir;
      mode = "750";
      user = config.systemd.services.postgresql.serviceConfig.User;
      group = config.systemd.services.postgresql.serviceConfig.Group;
    }
  ];
}
