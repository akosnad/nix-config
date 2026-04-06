{ inputs
, lib
, config
, ...
}:
let
  prefix = "hosts/";
in
{
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module:
        let
          hostName = lib.removePrefix prefix name;
          specialArgs = {
            inherit inputs;
            hostConfig = {
              name = hostName;
            };
          };
        in
        {
          name = hostName;
          value = inputs.nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = [
              module
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.extraSpecialArgs = specialArgs;
              }
              {
                home-manager.sharedModules = lib.pipe config.flake.modules.homeManager [
                  (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
                  lib.attrValues
                ];
              }
            ];
          };
        }
    ))
  ];

  perSystem =
    { pkgs, ... }:
    {
      checks = lib.pipe config.flake.nixosConfigurations [
        (lib.filterAttrs (_: c: c.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system))
        (lib.mapAttrs' (name: c: lib.nameValuePair "nixos-${name}" c.config.system.build.toplevel))
      ];
    };
}
