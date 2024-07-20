{ config, ... }:
let
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
