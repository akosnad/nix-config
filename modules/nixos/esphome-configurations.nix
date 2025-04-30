{ pkgs, lib, config, inputs, ... }:
let
  inherit (lib) types;
  cfg = config.services.esphome.configurations;
  configurationModule = import ../common/esphome.nix;
  deviceSettingsFormat = pkgs.formats.yaml { };

  defaultSettings = name: {
    esphome = {
      inherit name;
    };
    wifi = {
      ssid = "!secret wifi_ssid";
      password = "!secret wifi_pass";
      domain = ".${config.networking.domain}";
      ap = {
        # careful: can't be longer than 32 chars!
        ssid = "${name} fallback";
        password = "!secret wifi_fallback_pass";
      };
      manual_ip =
        if lib.hasAttr name config.devices then
          {
            static_ip = config.devices."${name}".ip;
            subnet = "255.0.0.0";
            gateway = config.devices.gaia.ip;
            dns1 = config.devices.gaia.ip;
          } else { };
    };
    ota = {
      platform = "esphome";
      password = "!secret ota_pass";
    };
    logger = { };
    api = { };
    captive_portal = { };
  };

  # borrowed from nixpkgs: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/home-automation/home-assistant.nix
  # 
  # Post-process YAML output to add support for YAML functions, like
  # secrets or includes, by naively unquoting strings with leading bangs
  # and at least one space-separated parameter.
  # https://www.home-assistant.io/docs/configuration/secrets/
  renderDeviceSettingsFile =
    fn: yaml:
    pkgs.runCommandLocal fn { } ''
      cp ${deviceSettingsFormat.generate fn yaml} $out
      sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
    '';

  settingFiles = lib.pipe cfg [
    (lib.mapAttrs (name: cfg: lib.recursiveUpdate (defaultSettings name) cfg.settings))
    (lib.mapAttrs (name: cfg: renderDeviceSettingsFile "${name}.yaml" cfg))
    (lib.mapAttrs' (name: cfg: lib.nameValuePair "${name}.yaml" cfg))
  ];

  firmwareUpdateScript = pkgs.writeShellApplication {
    name = "esphome-update-device";
    runtimeInputs = with pkgs; [ esphome ];
    text = ''
      ln -sf "$CREDENTIALS_DIRECTORY"/esphome-secrets ./secrets.yaml
      ln -sf /etc/esphome/"$1" ./"$1"
      esphome run --no-logs "$1"
    '';
  };

  mkUpdateService = name: _cfg: {
    description = "ESPHome firmware updater for ${name}";
    environment = {
      PLATFORMIO_CORE_DIR = "/var/lib/esphome/.platformio";
    };
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe firmwareUpdateScript} ${name}.yaml";
      DynamicUser = true;
      User = "esphome";
      Group = "esphome";
      WorkingDirectory = "/var/lib/esphome";
      StateDirectory = "esphome";
      StateDirectoryMode = "0750";
      Restart = "on-failure";

      # Hardening
      # taken from: https://github.com/NixOS/nixpkgs/blob/330d0a4167924b43f31cc9406df363f71b768a02/nixos/modules/services/home-automation/esphome.nix#L111C1-L145C24
      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      DevicePolicy = "closed";
      #NoNewPrivileges = true; # Implied by DynamicUser
      PrivateUsers = true;
      #PrivateTmp = true; # Implied by DynamicUser
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = false; # breaks bwrap
      ProtectKernelLogs = false; # breaks bwrap
      ProtectKernelModules = true;
      ProtectKernelTunables = false; # breaks bwrap
      ProtectProc = "invisible";
      ProcSubset = "all"; # Using "pid" breaks bwrap
      ProtectSystem = "strict";
      #RemoveIPC = true; # Implied by DynamicUser
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
      RestrictNamespaces = false; # Required by platformio for chroot
      RestrictRealtime = true;
      #RestrictSUIDSGID = true; # Implied by DynamicUser
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "@mount" # Required by platformio for chroot
      ];
      UMask = "0077";
      LoadCredential = "esphome-secrets:${config.sops.secrets.esphome-secrets.path}";
    };
  };

  mkUpdateTimer = name: cfg: {
    description = "Scheduled ESPHome firmware update for ${name}";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnCalendar = cfg.autoUpdate.onCalendar;
      Persistent = true;
    };
  };

  mkSystemdUnits = mapFn: lib.mapAttrs' (name: cfg: lib.nameValuePair "esphome-update-${name}" (mapFn name cfg)) cfg;
in
{
  options.services.esphome = {
    configurations = lib.mkOption {
      description = ''
        ESPHome device configurations.
      '';
      type = types.attrsOf (types.submodule configurationModule);
      default = { };
    };
  };
  config = lib.mkIf config.services.esphome.enable {
    services.esphome.configurations = inputs.self.esphomeConfigurations;

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
