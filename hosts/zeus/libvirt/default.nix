{ pkgs, ... }:
let
  ovmf = (pkgs.OVMF.override {
    secureBoot = true;
    tpmSupport = true;
  }).fd;
in
{
  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = true;
    connections."qemu:///system" = {
      domains = [
        {
          definition = import ./hassos-vm.nix { inherit ovmf pkgs; };
          active = false;
        }
      ];
      pools = [
        {
          definition = ./images.xml;
          active = true;
        }
      ];
    };
  };
}
