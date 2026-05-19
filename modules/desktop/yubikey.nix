let
  flake.modules.nixos.yubikey =
    { pkgs, ... }:
    {
      services.pcscd.enable = true;
      environment.systemPackages = with pkgs; [
        yubikey-manager
        pcsc-tools
      ];

      environment.etc."gnupg/scdaemon.conf".text = "disable-ccid";
    };
  flake.modules.nixos.desktop = {
    imports = [ flake.modules.nixos.yubikey ];
  };
in
{
  inherit flake;
}
