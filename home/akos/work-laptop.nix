{ lib, ... }:
{
  imports = [
    ./global
    ./features/helix/full.nix
    ./features/shell/full.nix
  ];

  home.persistence = lib.mkForce { };
  services.gpg-agent.enable = lib.mkForce false;
  programs.gpg.enable = lib.mkForce false;
}
