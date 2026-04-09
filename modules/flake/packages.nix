{ inputs
, config
, ...
}:
let
  flakeConfig = config;
  localPackages =
    pkgs:
    pkgs.lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ../../pkgs/by-name;
    };

in
{
  perSystem =
    { lib
    , pkgs
    , system
    , ...
    }:
    {
      config = {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = lib.attrValues flakeConfig.flake.overlays;
        };
        _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
          inherit system;
          overlays = lib.attrValues flakeConfig.flake.overlays;
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
          flattenPackages "" (localPackages pkgs);
      };
    };

  flake.overlays.default = _final: localPackages;
}
