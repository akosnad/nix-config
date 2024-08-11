{ inputs, ... }:
{
  nixvirt = inputs.nixvirt.nixosModules.default;
  home-assistant = import ./home-assistant;
}
