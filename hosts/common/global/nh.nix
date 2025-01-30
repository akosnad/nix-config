{ inputs, lib, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = lib.mkDefault true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = inputs.self;
  };
}
