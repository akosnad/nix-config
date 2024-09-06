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
in
{
  system.autoUpgrade = {
    enable = isClean;
    dates = lib.mkDefault "hourly";
    flags = [ "--refresh" ];
    flake = "github:akosnad/nix-config";
  };

  # Only run if current config (self) is older than the new one.
  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig.ExecCondition = lib.getExe (
      pkgs.writeShellApplication {
        name = "check-nixos-upgrade";
        runtimeInputs = with pkgs; [ jq ];
        text = ''
          lastModified() {
            nix flake metadata "$1" --refresh --json | jq '.lastModified'
          }

          # check if latest upstream config is newer than current
          test "$(lastModified "${config.system.autoUpgrade.flake}")"  -gt "$(lastModified "self")"

          # check if system derivation is built upstream (i.e. by CI/CD)
          uri="${config.system.autoUpgrade.flake}#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel"
          test "$(nix path-info --refresh --json "$uri" | jq '.[0].valid')" -eq "true"
        '';
      });
  };
}
