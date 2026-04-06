let
  config = import ./_nixpkgs-config.nix;
in
{
  flake.modules.homeManager.base = {
    nixpkgs = { inherit config; };
    xdg.configFile."nixpkgs/config.nix".source = ./_nixpkgs-config.nix;
  };

  flake.modules.nixos.base = {
    nixpkgs = { inherit config; };
  };
}
