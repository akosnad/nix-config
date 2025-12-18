{ pkgs, lib, config, inputs, ... }:
let
  inherit (lib) types;
  dockerImage = "ghcr.io/esphome/esphome";
  cfg = config.services.esphome-updater;
  configurationModule = lib.modules.importApply ../../common/esphome.nix { inherit pkgs; };
  deviceSettingsFormat = pkgs.formats.yaml { };

  defaultSettings = name: lib.recursiveUpdate
    {
      esphome = {
        inherit name;
        project.name = "akosnad.nix-config";
      };
      wifi = {
        ssid = "!secret wifi_ssid";
        password = "!secret wifi_pass";
        domain = ".${config.networking.domain}";
      };
      ota = {
        platform = "esphome";
        password = "!secret ota_pass";
      };
      logger = { };
      api = { };
    }
    (if lib.hasAttr name config.devices then {
      wifi.manual_ip = {
        static_ip = config.devices."${name}".ip;
        subnet = "255.0.0.0";
        gateway = config.devices.gaia.ip;
        dns1 = config.devices.gaia.ip;
      };
    } else { });

  # borrowed from nixpkgs: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/home-automation/home-assistant.nix
  # 
  # Post-process YAML output to add support for YAML functions, like
  # secrets or includes, by naively unquoting strings with leading bangs
  # and at least one space-separated parameter.
  # https://www.home-assistant.io/docs/configuration/secrets/
  renderDeviceSettingsFile =
    fn: yaml:
    pkgs.runCommandLocal fn { } ''
      temp=$(mktemp)
      cp ${deviceSettingsFormat.generate fn yaml} $temp
      storeHash=$(sed -E 's/^\/nix\/store\/([0-9a-z]{32}).*$/\1/' <<<"$out")
      ${lib.getExe pkgs.yq-go} -i ".esphome.project.version = \"$storeHash\"" $temp
      sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $temp
      cp $temp $out
    '';

  settingFiles = lib.pipe cfg.configurations [
    (lib.mapAttrs (name: cfg: lib.recursiveUpdate (defaultSettings name) cfg.settings))
    (lib.mapAttrs (name: cfg: renderDeviceSettingsFile "${name}.yaml" cfg))
    (lib.mapAttrs' (name: cfg: lib.nameValuePair "${name}.yaml" cfg))
  ];

  firmwareUpdateScript = pkgs.writeShellApplication {
    name = "esphome-update-device";
    runtimeInputs = with pkgs; [ bash util-linux ];
    text = ''
      exec 200>/var/lib/esphome/.update-device.lock
      # only allow a single instance to run at a time
      # and block until it's our turn
      flock -x 200

      cp "$CREDENTIALS_DIRECTORY"/esphome-secrets ./secrets.yaml
      cp /etc/esphome/"$1" ./"$1"
      ${lib.getExe config.virtualisation.docker.package} \
        run --rm --network=host \
        -v "$PWD":/config \
        ${dockerImage}:"$2" \
        run --no-logs "$1"
    '';
  };

  firmwareUpdateCheckScript = pkgs.stdenv.mkDerivation rec {
    name = "esphome-firmware-version-check";
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (ps: with ps; [
        aioesphomeapi
      ]))
    ];
    dontUnpack = true;
    installPhase = "install -Dm755 ${./esphome-firmware-version-check.py} $out/bin/${name}";
    meta.mainProgram = name;
  };

  updateConditionScript = pkgs.writeShellApplication {
    name = "esphome-check-needs-update";
    runtimeInputs = (with pkgs; [ bash util-linux ]) ++ [ firmwareUpdateCheckScript ];
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

  mkUpdateService = name: cfg:
    let
      mkIfNotScheduled = lib.mkIf (builtins.isNull cfg.autoUpdate.schedule);
    in
    lib.mkIf cfg.autoUpdate.enable {
      description = "ESPHome firmware updater for ${name}";
      environment = {
        # fixes esp-idf compile error
        # reference: https://github.com/NixOS/nixpkgs/issues/339557
        PLATFORMIO_CORE_DIR = "/var/lib/private/esphome/.platformio";
      };
      after = [ "network.target" "docker.socket" ];
      wants = [ "docker.socket" ];
      wantedBy = mkIfNotScheduled [ "multi-user.target" ];
      restartIfChanged = mkIfNotScheduled true;
      restartTriggers = mkIfNotScheduled [ config.environment.etc."esphome/${name}.yaml".source ];
      startLimitIntervalSec = 30;
      startLimitBurst = 3;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecCondition = "${lib.getExe updateConditionScript} ${name} ${cfg.frameworkVersion}";
        ExecStartPre = "${lib.getExe preUpdateScript} ${cfg.frameworkVersion}";
        ExecStart = "${lib.getExe firmwareUpdateScript} ${name}.yaml ${cfg.frameworkVersion}";
        WorkingDirectory = "/var/lib/esphome";
        StateDirectory = "esphome";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
        LoadCredential = "esphome-secrets:${config.sops.secrets.esphome-secrets.path}";
        UMask = "077";
      };
    };

  mkUpdateTimer = name: cfg: lib.mkIf (!(builtins.isNull cfg.autoUpdate.schedule)) {
    description = "Scheduled ESPHome firmware update for ${name}";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnCalendar = cfg.autoUpdate.schedule;
      Persistent = true;
    };
  };

  mkSystemdUnits = mapFn: lib.mapAttrs' (name: cfg: lib.nameValuePair "esphome-update-${name}" (mapFn name cfg)) cfg.configurations;
in
{
  options.services.esphome-updater = {
    enable = lib.mkOption {
      description = ''
        Enable creation of ESPHome device OTA updater services
      '';
      type = types.bool;
      default = false;
    };
    configurations = lib.mkOption {
      description = ''
        ESPHome device configurations.
      '';
      type = types.attrsOf (types.submodule configurationModule);
      default = { };
    };
  };
  config = lib.mkIf config.services.esphome-updater.enable {
    virtualisation.docker.enable = true;
    services.esphome-updater.configurations = lib.flip lib.mapAttrs inputs.self.esphomeConfigurations
      (_: cfg: lib.recursiveUpdate cfg (if builtins.isNull cfg.frameworkVersion then { frameworkVersion = config.services.esphome.package.version; } else { }));

    environment.etc = lib.mapAttrs'
      (target: source: lib.nameValuePair "esphome/${target}" {
        inherit source;
        user = "esphome";
        group = "esphome";
      })
      settingFiles;

    systemd.services = mkSystemdUnits mkUpdateService;
    systemd.timers = mkSystemdUnits mkUpdateTimer;
  };
}
