{ pkgs, ... }:
{
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-manager
    pcsc-tools
  ];

  environment.etc."gnupg/scdaemon.conf".text = "disable-ccid";
}
