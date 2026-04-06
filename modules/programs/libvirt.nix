{ config, ... }:
{
  config.flake.modules.nixos.libvirt =
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
    };

  config.flake.modules.nixos.virt-manager =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.nixos.libvirt
      ];

      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        virtio-win
        win-spice
      ];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
          };
        };
        spiceUSBRedirection.enable = true;
      };

      services.spice-vdagentd.enable = true;

      environment.persistence."/persist".directories = [ "/var/lib/libvirt" ];
    };
}
