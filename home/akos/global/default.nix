{ inputs, outputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.spicetify.homeManagerModules.spicetify
    ../features/shell
    ../features/helix
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = import ./nixpkgs-config.nix;
  };
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "ca-derivations" "dynamic-derivations" "recursive-nix" ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix.fzt.one/"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix.fzt.one-1:W6+n+PqYiAINgEUYnAxoDrV0xrjPR0C0fJeIDp3nvAw="
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

  sops.sopsFile = ../secrets.yaml;

  stylix.targets.gnome.enable = lib.mkForce false;
  stylix.targets.kde.enable = lib.mkForce false;

  home = {
    file = {
      ".yubico/authorized_yubikeys".text = "${config.home.username}:cccccbkcfrgn";
    };
    username = lib.mkDefault "akos";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";

    persistence = {
      "/persist" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          "src"
          ".local/bin"
          ".local/share/nix" # trusted settings and repl history
        ];
      };
    };
  };
}
