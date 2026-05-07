{ lib, ... }:
let
  inherit (lib) mkOption types mkIf literalExpression pipe filterAttrs mapAttrsToList;
in
{
  flake.modules.nixos.base = { pkgs, config, ... }:
    let
      tomlFormat = pkgs.formats.toml { };
      cfg = config.services.obelisk;
    in
    {
      options = {
        services.obelisk = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Enable Obelisk: Durable & Deterministic Workflow Engine.
            '';
          };
          package = mkOption {
            type = types.package;
            default = pkgs.obelisk;
            description = ''
              Obelisk package to use.
            '';
          };
          serverConfig = mkOption {
            inherit (tomlFormat) type;
            default = {
              api.listening_addr = "${cfg.api.listenAddress}:${toString cfg.api.port}";
              webui.listening_addr = "${cfg.webui.listenAddress}:${toString cfg.webui.port}";

              database.sqlite = {
                directory = "${cfg.dataDir}/obelisk-sqlite";
                pragma = { cache_size = "10000"; synchronous = "FULL"; };
              };

              wasm = {
                cache_directory = "${cfg.cacheDir}/wasm";
                backtrace.persist = true;
                allocator_config = "auto";
                global_executor_instance_limiter = "unlimited";
                global_webhook_instance_limiter = "unlimited";
                fuel = "unlimited";
                parallel_compilation = true;
                codegen_cache = {
                  enabled = true;
                  directory = "${cfg.cacheDir}/codegen";
                };
              };

              activities.directories = {
                enabled = false;
                parent_directory = "${cfg.dataDir}/activities";
                cleanup = {
                  enabled = true;
                  run_every.minutes = 1;
                  older_than.minutes = 5;
                };
              };

              workflows = {
                lock_extension_leeway.milliseconds = 100;
              };

              http_server =
                let
                  extraServers = pipe cfg.webhookServers [
                    (filterAttrs (_: { listenAddress, port }: !(listenAddress == "127.0.0.1" && port == 9090)))
                    (mapAttrsToList (name: { listenAddress, port }: { inherit name; listening_addr = "${listenAddress}:${toString port}"; }))
                  ];

                in
                mkIf (extraServers != [ ]) extraServers;
            };
            description = ''
              `server.toml` configuration.

              See <https://obeli.sk/docs/latest/configuration/> for the full list of options.
            '';
          };
          deploymentConfig = mkOption {
            inherit (tomlFormat) type;
            default = { };
            description = ''
              `deployment.toml` configuration.

              See <https://obeli.sk/docs/latest/configuration/> for the full list of options.
            '';
          };
          webui = {
            listenAddress = mkOption {
              type = types.str;
              default = "127.0.0.1";
            };
            port = mkOption {
              type = types.int;
              default = 8080;
            };
          };
          api = {
            listenAddress = mkOption {
              type = types.str;
              default = "127.0.0.1";
            };
            port = mkOption {
              type = types.int;
              default = 5005;
            };
          };
          webhookServers = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                listenAddress = mkOption {
                  type = types.str;
                  default = "127.0.0.1";
                };
                port = mkOption {
                  type = types.int;
                  default = 9090;
                };
              };
            });
            default = { };
            example = literalExpression ''
              {
                local = { listenAddress = "127.0.0.1"; port = 1234; }
                public = { listenAddress = "1.2.3.4"; port= 4567; }
              }
            '';
          };
          dataDir = mkOption {
            type = types.str;
            default = "/var/lib/obelisk";
            description = ''
              Data directory.
            '';
          };
          cacheDir = mkOption {
            type = types.str;
            default = "/var/cache/obelisk";
            description = ''
              Cache directory.
            '';
          };
        };
      };

      config =
        let
          serverFile = tomlFormat.generate "server.toml" cfg.serverConfig;
          deploymentFile = tomlFormat.generate "deployment.toml" cfg.deploymentConfig;
        in
        mkIf cfg.enable {
          environment.etc = {
            "obelisk/server.toml".source = serverFile;
            "obelisk/deployment.toml".source = deploymentFile;
          };
          users = {
            users.obelisk = {
              isSystemUser = true;
              group = "obelisk";
            };
            groups.obelisk = { };
          };
          systemd.services.obelisk = {
            preStart = ''${cfg.package}/bin/obelisk server verify --server-config /etc/obelisk/server.toml --deployment /etc/obelisk/deployment.toml'';
            script = ''${cfg.package}/bin/obelisk server run --server-config /etc/obelisk/server.toml --deployment /etc/obelisk/deployment.toml'';
            wantedBy = [ "multi-user.target" ];
            restartTriggers = [ serverFile deploymentFile ];
            serviceConfig = {
              User = "obelisk";
              Group = "obelisk";
              PrivateTmp = true;
            };
          };
        };
    };
}
