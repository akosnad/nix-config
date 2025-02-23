system: { inputs, pkgs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/netboot/netboot-base.nix"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = system;

  environment.systemPackages = with pkgs; [
    helix
  ];

  system.stateVersion = "24.11";
}
