{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.services.headscale;
  policyFormat = pkgs.formats.json { };
  policyFile = policyFormat.generate "headscale-policy.json" cfg.policy;
in
{
  options.services.headscale.policy = mkOption {
    type = types.submodule {
      freeformType = policyFormat.type;
      options = { };
    };
  };

  config.services.headscale.settings.policy.path = lib.mkIf (cfg.settings.policy.mode == "file") policyFile;
}
