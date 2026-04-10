{ lib, ... }:
{
  perSystem = { system, config, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixpkgs-fmt.enable = true;
        rustfmt.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        shfmt.enable = true;
        black.enable = true;
      };
    };

    # treefmt is slow on emulated aarch64-linux,
    # so this disables that check
    treefmt.flakeCheck = false;
    checks = lib.mkIf (system == "x86_64-linux") {
      # source: https://github.com/numtide/treefmt-nix/blob/790751ff7fd3801feeaf96d7dc416a8d581265ba/flake-module.nix#L74
      treefmt = config.treefmt.build.check config.treefmt.projectRoot;
    };
  };
}
