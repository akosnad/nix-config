{ lib, ... }:
{
  imports = [
    ./global
    ./features/helix/full.nix
    ./features/shell/full.nix
    ./features/vscode-server.nix
    ./features/desktop/common/wayland/waypipe.nix
  ];

  home.persistence = lib.mkForce { };
  services.gpg-agent.enable = lib.mkForce false;
  programs.gpg.enable = lib.mkForce false;
}
