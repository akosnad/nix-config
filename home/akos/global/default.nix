{ inputs, outputs, pkgs, lib, config, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
    ../features/shell
    ../features/nvim
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  colorscheme = lib.mkOverride 1499 colorSchemes.darkmoss;

  # TODO: dark and light mode specialisations
  # specialisation = {
  #   dark.configuration.colorscheme = lib.mkOverride 1498 config.colorscheme;
  #   light.configuration.colorscheme = lib.mkOverride 1498 config.colorscheme;
  # };

  home = {
    username = lib.mkDefault "akos";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
  };
}
