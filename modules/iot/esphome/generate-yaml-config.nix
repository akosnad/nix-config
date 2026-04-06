{ config, lib, ... }:
let
  inherit (config.flake) devices;
  cfg = config.flake.esphomeHosts;
in
{
  perSystem =
    { system, pkgs, ... }:
    if system != "x86_64-linux" then
      { }
    else
      let
        deviceSettingsFormat = pkgs.formats.yaml { };

        defaultSettings =
          name:
          lib.recursiveUpdate
            {
              esphome = {
                inherit name;
                project.name = "akosnad.nix-config";
              };
              wifi = {
                ssid = "!secret wifi_ssid";
                password = "!secret wifi_pass";
                domain = ".home.arpa";
              };
              ota = {
                platform = "esphome";
                password = "!secret ota_pass";
              };
              logger = { };
              api = { };
            }
            (
              if lib.hasAttr name devices then
                {
                  wifi.manual_ip = {
                    static_ip = devices."${name}".ip;
                    subnet = "255.0.0.0";
                    gateway = devices.gaia.ip;
                    dns1 = devices.gaia.ip;
                  };
                }
              else
                { }
            );

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

      in
      {
        checks = lib.pipe cfg [
          (lib.mapAttrs (name: cfg: lib.recursiveUpdate (defaultSettings name) cfg.config.settings))
          (lib.mapAttrs (name: cfg: renderDeviceSettingsFile "${name}.yaml" cfg))
          (lib.mapAttrs' (name: cfg: lib.nameValuePair "esphome-${name}" cfg))
        ];
      };
}
