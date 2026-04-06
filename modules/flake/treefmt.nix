{
  perSystem.treefmt = {
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
}
