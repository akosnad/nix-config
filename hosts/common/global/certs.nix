{ config, ... }:
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
    "${../gaia-roots.pem}"
  ];
}
