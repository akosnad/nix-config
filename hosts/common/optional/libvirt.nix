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
    };
  };

  systemd.services.libvirt-guests.enable = false;
}
