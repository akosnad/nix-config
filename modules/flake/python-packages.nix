{ lib, ... }:
let
  mkLocalPythonPackages = callPackage: lib.filesystem.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ../../pkgs/development/python-modules;
  };
in
{
  perSystem = { pkgs, ... }: {
    config.localPackages =
      let
        localPythonPackages = mkLocalPythonPackages pkgs.python3Packages.callPackage;
      in
      (lib.mapAttrs' (n: lib.nameValuePair "python3Packages/${n}")) localPythonPackages;
  };

  flake.overlays.python-packages = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (prevPythonPkgs: _: (mkLocalPythonPackages prevPythonPkgs.callPackage))
    ];
  };
}
