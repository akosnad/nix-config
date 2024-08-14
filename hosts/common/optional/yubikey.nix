{ pkgs, ... }:
{
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-manager
    pcsc-tools
  ];
}
