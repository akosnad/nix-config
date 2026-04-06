{ inputs
, withSystem
, config
, ...
}:
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
          ];
        };

        localPackages = lib.filesystem.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ../../pkgs/by-name;
        };
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
