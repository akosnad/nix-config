{
  config.flake.modules.nixos.base =
    { config, lib, ... }:
    let
      hasCerts = lib.length (lib.attrNames config.security.acme.certs) > 0;
    in
    {
      security.acme = {
        defaults = {
          server = "https://gaia:4443/acme/acme/directory";
          email = "${config.networking.hostName}@lan";
          validMinDays = 14;
        };
        acceptTerms = true;
      };

      security.pki.certificateFiles = [
        "${./gaia-roots.pem}"
      ];

      # reference: https://emudhra.we-have-a-problem.com/
      security.pki.caCertificateBlacklist = [
        "Comodo AAA Services root"
        "emSign ECC Root CA - G3"
      ];

      environment.persistence."/persist".directories = lib.mkIf hasCerts [
        {
          directory = "/var/lib/acme";
          mode = "755";
          user = "acme";
          group = "acme";
        }
      ];
    };
}
