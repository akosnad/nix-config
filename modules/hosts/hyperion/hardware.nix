{ inputs, ... }:
{
  config.flake.modules.nixos."hosts/hyperion" = {
    imports = with inputs.hardware.nixosModules; [
      common-cpu-intel
      common-gpu-nvidia
      common-pc-ssd
    ];

    hardware.nvidia.prime.offload.enable = false;
  };
}
