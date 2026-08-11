{ config, lib, ... }:
{
  perSystem = { system, pkgs, ... }:
    let
      mkUpdater = { name, yaml, frameworkVersion ? pkgs.esphome.version }: {
        type = "app";
        program = lib.getExe (pkgs.writeShellApplication {
          name = "esphome-update-${name}";
          runtimeInputs = with pkgs; [
            bash
            sops
            docker
          ];
          text = ''
            mkdir -p ./esphome-build
            cd ./esphome-build/
            ln -sf ${yaml} ./${name}.yaml
            (
              umask 077
              sops decrypt \
                --input-type binary \
                --output-type binary \
                ${./secrets.yaml} \
                > ./secrets.yaml
            )

            docker \
                run --rm -it --network=host \
                --mount "type=bind,source=/nix/store,target=/nix/store,readonly" \
                -v "$PWD":/config \
                -v "$PWD"/.platformio:/root/.platformio \
                -v "$PWD"/.cache:/root/.cache \
                ghcr.io/esphome/esphome:${frameworkVersion} \
                run --no-logs "${name}.yaml" "$@"
          '';
        });
      };
    in
    {
      apps = lib.pipe config.flake.esphomeHosts [
        (lib.filterAttrs (_: config: config.config.buildPlatform == system))
        (lib.mapAttrs' (name: config: lib.nameValuePair "esphome-update-${name}" (mkUpdater {
          inherit name;
          inherit (config.config) yaml;
          frameworkVersion = if config.config.frameworkVersion == null then pkgs.esphome.version else config.config.frameworkVersion;
        })))
      ];
    };
}
