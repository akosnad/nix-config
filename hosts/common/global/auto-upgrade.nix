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
            revision() {
              nix flake metadata "$1" --refresh --json | jq -r '.revision'
            }

            checkBuilt() {
              # change for given revision
              change="$(curl -fs "${buildbotApi}/changes?field=revision&field=changeid" | jq -r ".changes[] | select(.revision == \"""$2""\") | .changeid")"
              # builder for given host
              builder="$(curl -fs "${buildbotApi}/builders?field=name&field=builderid" | jq -r ".builders[] | select(.name == \"""$1""\") | .builderid")"
              # latest build for given change and builder
              build="$(curl -fs "${buildbotApi}/changes/$change/builds?builderid__eq=$builder" | jq -Mcr '.builds | sort_by(.number) | reverse | first')"

              # check if build start date is not older than last revision (sanity check)
              test "$(jq -r '.started_at' <<< "$build")" -gt "$upstreamModified"

              # check if build has completed and is successful
              jq -e '.complete and .results == 0' <<< "$build" > /dev/null
            }

            # check if latest upstream config is newer than current
            upstreamModified="$(lastModified "${config.system.autoUpgrade.flake}")"
            test "$upstreamModified" -gt "$(lastModified "self")"

            # check if system derivation is built upstream (i.e. by CI/CD or available from substituters)
            newRevision="$(revision "${config.system.autoUpgrade.flake}")"
            checkBuilt "${config.system.autoUpgrade.flake}#checks.${config.nixpkgs.hostPlatform.system}.nixos-${config.networking.hostName}" "$newRevision"
          '';
        });

      ExecStart = lib.mkForce (lib.getExe (
        pkgs.writeShellApplication {
          name = "nixos-upgrade";
          runtimeInputs = with pkgs; [ curl jq nix ];
          text = ''
            revision() {
              nix flake metadata "$1" --refresh --json | jq -r '.revision'
            }

            getSystemPath() {
              # change for given revision
              change="$(curl -fs "${buildbotApi}/changes?field=revision&field=changeid" | jq -r ".changes[] | select(.revision == \"""$2""\") | .changeid")"
              # builder for given host
              builder="$(curl -fs "${buildbotApi}/builders?field=name&field=builderid" | jq -r ".builders[] | select(.name == \"""$1""\") | .builderid")"
              # latest build for given change and builder
              build="$(curl -fs "${buildbotApi}/changes/$change/builds?builderid__eq=$builder" | jq -Mcr '.builds | sort_by(.number) | reverse | first')"
              buildnumber="$(jq -r '.number' <<< "$build")"

              outPath="$(curl -fs "${buildbotApi}/builders/$builder/builds/$buildnumber/properties" | jq -r '.properties[0].out_path[0]')"
              nix-store --realise "$outPath" --no-fallback --max-silent-time 300 --timeout 1800
            }

            newRevision="$(revision "${config.system.autoUpgrade.flake}")"
            echo "Fetching system path for revision $newRevision ..."
            newPath="$(getSystemPath "${config.system.autoUpgrade.flake}#checks.${config.nixpkgs.hostPlatform.system}.nixos-${config.networking.hostName}" "$newRevision")"
            echo "Registering new system profile for $newPath ..."
            nix-env --profile /nix/var/nix/profiles/system --set "$newPath"
            echo "Activating new system profile ..."
            /nix/var/nix/profiles/system/bin/switch-to-configuration "${config.system.autoUpgrade.operation}"
            echo "Done."
          '';
        }));
    };
  };
}
