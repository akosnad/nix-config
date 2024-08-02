{ inputs, config, lib, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
  ];

  services.buildbot-nix.master = {
    enable = true;
    domain = "buildbot.fzt.one";
    workersFile = "/run/secrets/buildbot-workers";
    admins = [ "akosnad" ];
    github = {
      topic = "buildbot-akosnad";
      authType.app = {
        id = 960427;
        secretKeyFile = "/run/secrets/buildbot-nix-github-key";
      };
      webhookSecretFile = "/run/secrets/buildbot-webhook-secret";
      oauthId = "Ov23liqrF61WKdRZCwr7";
      oauthSecretFile = "/run/secrets/buildbot-github-oauth-secret";
    };
  };

  services.buildbot-master.extraConfig = ''
    c["protocols"] = {"pb": {"port": "tcp:9989:interface=\\:\\:"}}
  '';
  networking.firewall.allowedTCPPorts = [ 9989 ];

  sops.secrets =
    let
      owner = config.services.buildbot-master.user;
      masterSecretNames = [
        "buildbot-nix-github-key"
        "buildbot-webhook-secret"
        "buildbot-github-oauth-secret"
      ];
      masterSecrets = lib.genAttrs masterSecretNames (n: { inherit owner; sopsFile = ./secrets.yaml; });
    in
    (masterSecrets // { buildbot-workers = { sopsFile = ../common/secrets.yaml; inherit owner; }; });
}
