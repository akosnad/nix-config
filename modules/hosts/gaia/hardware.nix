{ inputs, ... }:
{
  config.flake.modules.nixos."hosts/gaia" = { pkgs, ... }: {
    imports = with inputs.hardware.nixosModules; [
      raspberry-pi-4
    ];

    # use upstream kernel instead of the vendor kernel
    # (we are not using any rPi specific hardware with quirks here)
    boot.kernelPackages = pkgs.linuxPackages;

    boot.kernelParams = [
      # tell the serial driver to use only one port,
      # without this it doesn't load.
      "8250.nr_uarts=1"
    ];
  };
}
