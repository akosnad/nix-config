{ pkgs, ... } @ args:
let
  config = pkgs.callPackage ./config.nix args;
  init = ''lua require([[${config}/init.lua]])'';
in
pkgs.symlinkJoin {
  name = "nvim-minimal";
  paths = [ pkgs.neovim-unwrapped ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --set VIMINIT '${init}'
  '';
}
