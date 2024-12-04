{ config, pkgs, lib, ... }:
{
  services.step-ca = {
    enable = true;
    intermediatePasswordFile = config.sops.secrets.step-ca-password.path;
    address = "0.0.0.0";
    port = 4443;
    settings = {
      root = config.sops.secrets.step-ca-root-ca.path;
      federatedRoots = null;
      crt = config.sops.secrets.step-ca-intermediate-ca.path;
      key = config.sops.secrets.step-ca-intermediate-ca-key.path;
      insecureAddress = "";
      dnsNames = [
        config.networking.hostName
        "${config.networking.hostName}.${config.networking.domain}"
        "10.20.0.1"
      ];
      logger.format = "text";
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority.provisioners = [{
        type = "ACME";
        name = "acme";
        claims = {
          enableSSHCA = true;
          disableRenewal = false;
          allowRenewalAfterExpiry = false;
          disableSmallstepExtensions = false;
        };
        options = {
          x509 = { };
          ssh = { };
        };
      }];
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };

  sops.secrets =
    let
      commonSecretOpts = {
        sopsFile = ../secrets.yaml;
        owner = "step-ca";
        group = "step-ca";
      };
      mkSecrets = names: lib.genAttrs names (_: commonSecretOpts);
    in
    mkSecrets [
      "step-ca-root-ca"
      "step-ca-intermediate-ca"
      "step-ca-intermediate-ca-key"
      "step-ca-password"
    ];

  environment.systemPackages = with pkgs; [
    step-cli
  ];
}
