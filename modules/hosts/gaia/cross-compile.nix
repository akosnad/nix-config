{ inputs, config, lib, ... }:
let
  linux-rpi = import "${inputs.hardware}/raspberry-pi/common/kernel.nix";
in
{
  flake.modules.nixos."hosts/gaia" =
    let
      pkgsCross = import inputs.nixpkgs {
        config = import ../../base/nixpkgs/_nixpkgs-config.nix;
        overlays = lib.attrValues config.flake.overlays;
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
      };
    in
    {
      # only cross compile the kernel
      boot.kernelPackages = pkgsCross.linuxPackagesFor (pkgsCross.callPackage linux-rpi { rpiVersion = 4; });
    };
}
