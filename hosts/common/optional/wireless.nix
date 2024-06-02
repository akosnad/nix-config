{ config, pkgs, lib, ... }:
let
  eduroam_ca_cert = pkgs.stdenv.mkDerivation {
    name = "eduroam-ca-cert";
    src = pkgs.fetchurl {
      url = "https://cat.eduroam.org/user/API.php?action=downloadInstaller&lang=en&profile=2142&device=linux&generatedfor=user&openroaming=0";
      sha256 = "sha256-8L5/D7zum5D0+GMkswNCj9sa0IdvOgZsg6B46UKSkKM=";
    };
    buildInputs = with pkgs; [ pcre.bin ];
    unpackPhase = ''
      mkdir -p $out
      cat $src | pcregrep -oM '\-\-\-\-\-BEGIN CERTIFICATE-----\n(.*\n)+?-----END CERTIFICATE-----' > $out/eduroam-ca-cert.pem
    '';
  };

  profileWithDefaults = { id, psk, ssid ? id }: {
    connection = {
      inherit id;
      type = "wifi";
    };
    ipv4 = { method = "auto"; };
    ipv6 = { addr-gen-mode = "stable-privacy"; method = "auto"; };
    proxy = { };
    wifi = {
      mode = "infrastructure";
      inherit ssid;
    };
    wifi-security = {
      inherit psk;
      key-mgmt = "wpa-psk";
    };
  };
in
{
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets.wireless.path ];

    profiles = {
      "Gaia" = profileWithDefaults {
        id = "Gaia";
        psk = "\${Gaia}";
      };

      "FBI Surveillance Van" = profileWithDefaults {
        id = "FBI Surveillance Van";
        psk = "\${FBI_Surveillance_Van}";
      };

      "PPKE-kollegium" = profileWithDefaults {
        id = "PPKE-kollegium";
        psk = "\${PPKE_kollegium}";
      };

      "hermes" = profileWithDefaults {
        id = "hermes";
        ssid = ".";
        psk = "\${hermes}";
      };

      eduroam = {
        connection = {
          id = "eduroam";
          type = "wifi";
        };
        ipv4 = { method = "auto"; };
        ipv6 = { addr-gen-mode = "stable-privacy"; method = "auto"; };
        proxy = { };
        wifi = {
          mode = "infrastructure";
          ssid = "eduroam";
        };
        wifi-security = { key-mgmt = "wpa-eap"; };
        "802-1x" = {
          eap = "peap";
          ca-path = "${eduroam_ca_cert}";
          anonymous-identity = "\${eduroam_anonymous_identity}";
          identity = "\${eduroam_identity}";
          password = "\${eduroam_password}";
          phase1-auth-flags = "32";
          phase2-auth = "mschapv2";
        };
      };
    };
  };
}
