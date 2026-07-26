{ lib, ... }:
let
  mkLocalComponents = callPackage: lib.filesystem.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ../../pkgs/home-assistant-custom-components;
  };
in
{
  perSystem = { pkgs, ... }: {
    config.localPackages =
      let
        localComponents = mkLocalComponents pkgs.home-assistant.python3Packages.callPackage;
      in
      (lib.mapAttrs' (n: lib.nameValuePair "home-assistant-custom-components/${n}")) localComponents;
  };

  flake.overlays.ha-custom-components = _final: prev: {
    home-assistant-custom-components = prev.home-assistant-custom-components //
      (mkLocalComponents prev.home-assistant.python3Packages.callPackage);
  };
}
