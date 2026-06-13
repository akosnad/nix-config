{ lib, config, ... }:
let
  esphomeHosts = lib.mapAttrs (_: h: h.config) config.flake.esphomeHosts;
in
{
  flake.modules.nixos.base =
    { pkgs, lib, config, ... }:
    let
      dockerImage = "ghcr.io/esphome/esphome";

      firmwareUpdateScript = pkgs.writeShellApplication {
        name = "esphome-update-device";
        runtimeInputs = with pkgs; [
          bash
          util-linux
        ];
        text = ''
          exec 200>/var/lib/esphome/.update-device.lock
          # only allow a single instance to run at a time
          # and block until it's our turn
          flock -x 200

          cp "$CREDENTIALS_DIRECTORY"/esphome-secrets ./secrets.yaml
          cp /etc/esphome/"$1" ./"$1"
          ${lib.getExe config.virtualisation.docker.package} \
            run --rm --network=host \
            --mount "type=bind,source=/nix/store,target=/nix/store,readonly" \
            -v "$PWD":/config \
            -v "$PWD"/.platformio:/root/.platformio \
            -v "$PWD"/.cache:/root/.cache \
            ${dockerImage}:"$2" \
            run --no-logs "$1"
        '';
      };

      firmwareUpdateCheckScript = pkgs.stdenv.mkDerivation rec {
        name = "esphome-firmware-version-check";
        propagatedBuildInputs = [
          (pkgs.python3.withPackages (
            ps: with ps; [
              aioesphomeapi
            ]
          ))
        ];
        dontUnpack = true;
        installPhase = "install -Dm755 ${./esphome-firmware-version-check.py} $out/bin/${name}";
        meta.mainProgram = name;
      };

      updateConditionScript = pkgs.writeShellApplication {
        name = "esphome-check-needs-update";
        runtimeInputs =
          (with pkgs; [
            bash
            util-linux
          ])
          ++ [ firmwareUpdateCheckScript ];
        text = ''
          targetConfig="$(realpath /etc/esphome/"$1".yaml)"
          storeHash=$(sed -E 's/^\/nix\/store\/([0-9a-z]{32}).*$/\1/' <<<"$targetConfig")
          esphome-firmware-version-check "$1" "$storeHash" "$2"
        '';
      };
      preUpdateScript = pkgs.writeShellApplication {
        name = "esphome-pre-update";
        text = ''
          ${lib.getExe config.virtualisation.docker.package} pull ${dockerImage}:"$1"
        '';
      };

      mkUpdateService =
        name: cfg:
        let
          mkIfNotScheduled = lib.mkIf (isNull cfg.autoUpdate.schedule);
          frameworkVersion = if isNull cfg.frameworkVersion then pkgs.esphome.version else cfg.frameworkVersion;
        in
        lib.mkIf cfg.autoUpdate.enable {
          description = "ESPHome firmware updater for ${name}";
          environment = {
            # fixes esp-idf compile error
            # reference: https://github.com/NixOS/nixpkgs/issues/339557
            PLATFORMIO_CORE_DIR = "/var/lib/private/esphome/.platformio";
          };
          after = [
            "network.target"
            "docker.socket"
          ];
          wants = [ "docker.socket" ];
          wantedBy = mkIfNotScheduled [ "multi-user.target" ];
          restartIfChanged = mkIfNotScheduled true;
          restartTriggers = mkIfNotScheduled [ config.environment.etc."esphome/${name}.yaml".source ];
          startLimitIntervalSec = 30;
          startLimitBurst = 3;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecCondition = "${lib.getExe updateConditionScript} ${name} ${frameworkVersion}";
            ExecStartPre = "${lib.getExe preUpdateScript} ${frameworkVersion}";
            ExecStart = "${lib.getExe firmwareUpdateScript} ${name}.yaml ${frameworkVersion}";
            WorkingDirectory = "/var/lib/esphome";
            StateDirectory = "esphome";
            StateDirectoryMode = "0750";
            Restart = "on-failure";
            LoadCredential = "esphome-secrets:${config.sops.secrets.esphome-secrets.path}";
            UMask = "077";
          };
        };

      mkUpdateTimer =
        name: cfg:
        lib.mkIf (!(isNull cfg.autoUpdate.schedule)) {
          description = "Scheduled ESPHome firmware update for ${name}";
          wantedBy = [ "multi-user.target" ];
          timerConfig = {
            OnCalendar = cfg.autoUpdate.schedule;
            Persistent = true;
          };
        };

      mkSystemdUnits =
        mapFn:
        lib.mapAttrs'
          (
            name: cfg: lib.nameValuePair "esphome-update-${name}" (mapFn name cfg)
          )
          esphomeHosts;
    in
    {
      config = lib.mkIf config.services.esphome-updater.enable {
        virtualisation.docker.enable = true;

        environment.etc = lib.mapAttrs'
          (
            name: c:
              lib.nameValuePair "esphome/${name}.yaml" {
                source = c.yaml;
                user = "esphome";
                group = "esphome";
              }
          )
          esphomeHosts;

        systemd.services = mkSystemdUnits mkUpdateService;
        systemd.timers = mkSystemdUnits mkUpdateTimer;
      };
    };

  flake.modules.nixos.esphome-updater = {
    services.esphome-updater.enable = true;
    sops.secrets.esphome-secrets = {
      # while this is a YAML file under the hood, the raw content is JSON,
      # as we want to pass the whole YAML content to ESPHome.
      # (this is how sops stores binary files)
      format = "binary";
      sopsFile = ./secrets.yaml;
    };

    environment.persistence."/persist".directories = [ "/var/lib/esphome" ];
  };
}
