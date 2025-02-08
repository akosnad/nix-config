{ config, lib, ... }:
let
  commonSettings = {
    homeserver = rec {
      domain = "m.fzt.one";
      address = "https://${domain}";
    };

    matrix = {
      message_status_events = true;
      delivery_receipts = true;
      message_error_notices = true;
      sync_direct_chat_list = true;
      federate_rooms = true;
    };

    bridge = {
      # Require encryption by default to make the bridge more secure
      encryption = {
        allow = true;
        default = true;
        require = true;

        # Recommended options from mautrix documentation
        # for optimal security.
        delete_keys = {
          dont_store_outbound = true;
          ratchet_on_decrypt = true;
          delete_fully_used_on_decrypt = true;
          delete_prev_on_new_session = true;
          delete_on_device_delete = true;
          periodically_delete_expired = true;
          delete_outdated_inbound = true;
        };

        verification_levels = {
          receive = "cross-signed-tofu";
          send = "cross-signed-tofu";
          share = "cross-signed-tofu";
        };

      };
      permissions = {
        "*" = "relay";
        "m.fzt.one" = "user";
        "@akosnad:m.fzt.one" = "admin";
      };
      login_shared_secret_map."m.fzt.one" = "$DOUBLEPUPPET_AS_TOKEN";
    };

    backfill = {
      enabled = true;
      max_initial_messages = 50;
      max_catchup_messages = 500;
      unread_hours_threshold = 720;
    };

    double_puppet = {
      servers = { };
      allow_discovery = false;
      secrets."m.fzt.one" = "as_token:$DOUBLEPUPPET_AS_TOKEN";
    };
  };
in
{

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.mautrix-meta = {
    instances = {
      messenger = {
        enable = true;
        registerToSynapse = true;
        environmentFile = config.sops.secrets.mautrix-meta-env.path;
        settings = lib.recursiveUpdate commonSettings {
          network.mode = "messenger";
          appservice = {
            id = "messengerbot";
            bot = {
              username = "messengerbot";
              displayname = "Messenger bridge bot";
              avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
            };
          };
        };
      };
      instagram = {
        enable = true;
        registerToSynapse = true;
        environmentFile = config.sops.secrets.mautrix-meta-env.path;
        settings = lib.recursiveUpdate commonSettings {
          network.mode = "instagram";
          appservice = {
            id = "instagrambot";
            bot = {
              username = "instagrambot";
              displayname = "Instagram brigde bot";
              avatar = "mxc://maunium.net/JxjlbZUlCPULEeHZSwleUXQv";
            };
          };
        };
      };
    };
  };

  sops.secrets.mautrix-meta-env = {
    sopsFile = ../secrets.yaml;
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${config.services.mautrix-meta.instances.messenger.dataDir}";
      user = "mautrix-meta-messenger";
      group = "mautrix-meta";
    }
    {
      directory = "/var/lib/${config.services.mautrix-meta.instances.instagram.dataDir}";
      user = "mautrix-meta-instagram";
      group = "mautrix-meta";
    }
  ];
}
