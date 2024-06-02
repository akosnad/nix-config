{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    onBoot = "start";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  systemd.services.libvirt-guests.enable = false;
}
