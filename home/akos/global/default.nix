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
      substituters = [
        "https://akosnad.cachix.org/"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "akosnad.cachix.org-1:mohKqHWc/aZqkAOWmPfvqRiHmhQ3wQ6R7g9ULwNaRfw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  colorscheme = lib.mkOverride 1499 colorSchemes.classic-dark;
  specialisation = {
    dark.configuration.colorscheme = lib.mkOverride 1498 colorSchemes.classic-dark;
    light.configuration.colorscheme = lib.mkOverride 1498 colorSchemes.classic-light;
  };

  home = {
    file = {
      ".colorscheme".text = config.colorscheme.slug;
      ".colorscheme.json".text = builtins.toJSON config.colorscheme;
    };
    username = lib.mkDefault "akos";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
  };

  home.packages =
    let
      specialisation = pkgs.writeShellScriptBin "specialisation" /* bash */ ''
        profiles="$HOME/.local/state/nix/profiles"
        current="$profiles/home-manager"
        base="$profiles/home-manager-base"

        # If current contains specialisations, link it as base
        if [ -d "$current/specialisation" ]; then
          echo >&2 "Using current profile as base"
          ln -sfT "$(readlink "$current")" "$base"
        # Check that $base contains specialisations before proceeding
        elif [ -d "$base/specialisation" ]; then
          echo >&2 "Using previously linked base profile"
        else
          echo >&2 "No suitable base config found. Try 'home-manager switch' again."
          exit 1
        fi

        if [ "$1" = "list" ] || [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
          find "$base/specialisation" -type l -printf "%f\n"
          exit 0
        fi

        echo >&2 "Switching to ''${1:-base} specialisation"
        if [ -n "$1" ]; then
          "$base/specialisation/$1/activate"
        else
          "$base/activate"
        fi
      '';
      toggle-theme = pkgs.writeShellScriptBin "toggle-theme" /* bash */ ''
        if [ -n "$1" ]; then
          theme="$1"
        else
          current="$(${lib.getExe pkgs.jq} -re '.variant' "$HOME/.colorscheme.json")"
          if [ "$current" = "light" ]; then
            theme="dark"
          else
            theme="light"
          fi
        fi
        ${lib.getExe specialisation} "$theme"
      '';
    in
    [
      specialisation
      toggle-theme
    ];
}
