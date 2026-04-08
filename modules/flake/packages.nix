{ inputs
, withSystem
, config
, ...
}:
let
  flakeConfig = config;
in
{
  perSystem =
    { lib
    , pkgs
    , system
    , config
    , ...
    }:
    {
      options.localPackages = lib.mkOption {
        type = lib.types.attrs;
      };

      config = {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (_final: prev: lib.recursiveUpdate prev config.localPackages)
          ] ++ (lib.attrValues flakeConfig.flake.overlays);
        };

        localPackages = lib.filesystem.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ../../pkgs/by-name;
        };

        packages =
          # flake output `packages` only allows a flat namespace, so we
          # need to flatten our packages before exposing them.
          #
          # this will result in for example:
          #   nodePackages.gree-hvac-mqtt-bridge -> "nodePackages/gree-hvac-mqtt-bridge"
          let
            flattenPackages =
              prefix: attrs:
              lib.concatMapAttrs
                (
                  name: value:
                  let
                    fullName = if prefix == "" then name else "${prefix}/${name}";
                  in
                  if lib.isDerivation value then
                    { ${fullName} = value; }
                  else if lib.isAttrs value then
                    flattenPackages fullName value
                  else
                    { }
                )
                attrs;
          in
          flattenPackages "" config.localPackages;
      };
    };

  flake.overlays.default =
    _final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: prev.lib.recursiveUpdate prev config.localPackages
    );

  flake.modules.nixos.base = {
    nixpkgs.overlays = [ config.flake.overlays.default ];
  };

  # TODO: provide local packages in the flake output, not just an overlay
}
