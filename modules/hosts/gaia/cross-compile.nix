{ inputs, config, lib, ... }:
{
  flake.modules.nixos."hosts/gaia" =
    let
      pkgsCross = import inputs.nixpkgs {
        config = import ../../base/nixpkgs/_nixpkgs-config.nix;
        overlays = lib.attrValues config.flake.overlays;
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
      };
      sops-cross = import inputs.sops-nix { pkgs = pkgsCross; };
    in
    {
      sops.package = sops-cross.sops-install-secrets;
    };
}
