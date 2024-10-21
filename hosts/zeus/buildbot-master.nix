{ inputs, config, lib, ... }:
let
  domain = "buildbot.fzt.one";
  masterSecretNames = [
    "buildbot-github-app-key"
    "buildbot-webhook-secret"
    "buildbot-github-oauth-secret"
  ];
  masterSecrets = lib.genAttrs masterSecretNames (_n: { sopsFile = ./secrets.yaml; neededForUsers = true; });

  secretsCfg = config.sops.secrets;
in
{
  containers.buildbot-master = {
    autoStart = true;
    hostBridge = "br0";
    nixpkgs = inputs.buildbot-nix.inputs.nixpkgs.legacyPackages.${config.nixpkgs.hostPlatform.system}.path;
    specialArgs = { buildbot-nix = inputs.buildbot-nix.nixosModules; };
    config = { lib, buildbot-nix, ... }: {
      imports = [
        buildbot-nix.buildbot-master
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
        cachix = {
          enable = true;
          name = "akosnad";
          auth.authToken.file = "${secretsCfg.buildbot-cachix-token.path}";
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

      system.stateVersion = "23.11";
      networking = {
        firewall.enable = false;
        useHostResolvConf = lib.mkForce false;
      };
      services.resolved.enable = true;
    };
  };

  sops.secrets =
    masterSecrets
    // {
      buildbot-workers = { sopsFile = ../common/secrets.yaml; neededForUsers = true; };
      buildbot-cachix-token = { sopsFile = ./secrets.yaml; neededForUsers = true; };
    };

  containers.buildbot-master.bindMounts = (builtins.listToAttrs (map (name: { name = secretsCfg.${name}.path; value = { isReadOnly = true; }; }) masterSecretNames)) // {
    "${config.sops.secrets.buildbot-workers.path}".isReadOnly = true;
    "${config.sops.secrets.buildbot-cachix-token.path}".isReadOnly = true;
    buildbot-data =
      let
        path = "/var/lib/buildbot";
      in
      {
        isReadOnly = false;
        mountPoint = path;
        hostPath = "/persist/${path}";
      };
  };
}
