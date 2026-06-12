{ lib, ... }:
{
  config.flake.modules.nixos."hosts/uranus" = { config, ... }:
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

        encryption = {
          allow = true;
          default = true;
          require = true;

          verification_levels = {
            receive = "cross-signed-untrusted";
            send = "cross-signed-untrusted";
            share = "cross-signed-untrusted";
          };

          # all are disabled due to buggy clients
          # reference: https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html#additional-security
          delete_keys = {
            delete_outbound_on_ack = false;
            dont_store_outbound = false;
            ratchet_on_decrypt = false;
            delete_fully_used_on_decrypt = false;
            delete_prev_on_new_session = false;
            delete_on_device_delete = false;
            periodically_delete_expired = false;
            delete_outdated_inbound = false;
          };
        };

        bridge = {
          # Require encryption by default to make the bridge more secure
          permissions = {
            "*" = "relay";
            "m.fzt.one" = "user";
            "@akosnad:m.fzt.one" = "admin";
          };
          login_shared_secret_map."m.fzt.one" = "as_token:$DOUBLEPUPPET_AS_TOKEN";
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
      services.mautrix-meta = {
        instances = {
          messenger = {
            enable = true;
            registerToSynapse = true;
            environmentFile = config.sops.secrets.mautrix-env.path;
            settings = lib.recursiveUpdate commonSettings {
              network = {
                mode = "messenger";
                displayname_template = "{{ or .DisplayName .Username .ID }}";
              };
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
            environmentFile = config.sops.secrets.mautrix-env.path;
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

      services.mautrix-whatsapp = {
        enable = true;
        registerToSynapse = true;
        environmentFile = config.sops.secrets.mautrix-env.path;
        settings = lib.recursiveUpdate commonSettings {
          appservice = {
            id = "whatsappbot";
            bot = {
              username = "whatsappbot";
              displayname = "WhatsApp bridge bot";
            };
          };
        };
      };

      sops.secrets.mautrix-env = {
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
        {
          directory = "/var/lib/mautrix-whatsapp";
          user = "mautrix-whatsapp";
          group = "mautrix-whatsapp";
        }
      ];
    };
}
