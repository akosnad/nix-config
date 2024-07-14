{ pkgs, inputs, ... }:
let
  config = {
    # TODO: make this configurable
    colorScheme = inputs.nix-colors.colorSchemes.default-dark;
  };
  hm-config = import ../../home/akos/features/nvim { inherit pkgs config; lib = pkgs.lib; };

  init-vim = pkgs.writeText "init.vim" hm-config.programs.neovim.extraConfig;
  init-lua = pkgs.writeText "init.lua" (builtins.concatStringsSep "\n" [
    "vim.cmd [[source ${init-vim}]]"
    hm-config.programs.neovim.extraLuaConfig
  ]);
in
pkgs.stdenv.mkDerivation {
  name = "nvim-minimal-config";

  unpackPhase = ''
    mkdir -p $out
  '';
  installPhase = ''
    mkdir -p $out
    ln -s "${init-lua}" $out/init.lua
  '';
}
