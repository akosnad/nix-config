{ pkgs, ... } @ args: {
  # example = pkgs.callPackage ./example { };
  nvim-minimal = pkgs.callPackage ./nvim-minimal args;
}
