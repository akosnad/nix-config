{ config
, inputs
, pkgs
, lib
, ...
}:
let
  # Only enable auto upgrade if current config came from a clean tree
  # This avoids accidental auto-upgrades when working locally.
  isClean = inputs.self ? rev;

  buildbotApi = "https://buildbot.fzt.one/api/v2";
in
{
  system.autoUpgrade = {
    enable = isClean;
    dates = lib.mkDefault "hourly";
    flags = [ "--refresh" "--accept-flake-config" ];
    flake = "github:akosnad/nix-config";
  };

  # Only run if current config (self) is older than the new one.
  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig = {
      # set a low priority
      Nice = "15";
      IOSchedulingPriority = "7";

      ExecCondition = lib.getExe (
        pkgs.writeShellApplication {
          name = "check-nixos-upgrade";
          runtimeInputs = with pkgs; [ curl jq ];
          text = ''
            lastModified() {
              nix flake metadata "$1" --refresh --json | jq '.lastModified'
            }

            checkBuilt() {
              builder="$(curl -fs "${buildbotApi}/builders" | jq -r ".builders[] | select(.name == \"""$1""\") | .builderid")"
              # TODO: querying build from revision instead of latest possible?
              build="$(curl -fs "${buildbotApi}/builders/$builder/builds" | jq -Mcr '.builds | sort_by(.number) | reverse | first')"

              # check if build start date is not older than last revision
              test "$(jq -r '.started_at' <<< "$build")" -gt "$upstreamModified"

              # check if build has completed and is successful
              jq -e '.complete and .results == 0' <<< "$build" > /dev/null
            }

            # check if latest upstream config is newer than current
            upstreamModified="$(lastModified "${config.system.autoUpgrade.flake}")"
            test "$upstreamModified" -gt "$(lastModified "self")"

            # check if system derivation is built upstream (i.e. by CI/CD or available from substituters)
            checkBuilt "${config.system.autoUpgrade.flake}#checks.${config.nixpkgs.hostPlatform.system}.nixos-${config.networking.hostName}"
          '';
        });
    };
  };
}
