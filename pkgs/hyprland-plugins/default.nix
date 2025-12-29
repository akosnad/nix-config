{ pkgs, inputs }:
let
  # borrowed from nixpkgs
  # source: https://github.com/NixOS/nixpkgs/blob/78d9f40fd6941a1543ffc3ed358e19c69961d3c1/pkgs/applications/window-managers/hyprwm/hyprland-plugins/default.nix#L10C1-L25C7
  mkHyprlandPlugin =
    hyprland:
    args@{ pluginName, ... }:
    pkgs.stdenv.mkDerivation (
      args
      // {
        pname = "${pluginName}";
        nativeBuildInputs = [ pkgs.pkg-config ] ++ args.nativeBuildInputs or [ ];
        buildInputs = [ hyprland ] ++ hyprland.buildInputs ++ (args.buildInputs or [ ]);
        meta = args.meta // {
          description = args.meta.description or "";
          longDescription =
            (args.meta.longDescription or "")
            + "\n\nPlugins can be installed via a plugin entry in the Hyprland NixOS or Home Manager options.";
        };
      }
    );
in
{
  hyprscroller = pkgs.callPackage ./hyprscroller.nix { inherit mkHyprlandPlugin pkgs inputs; };
}
