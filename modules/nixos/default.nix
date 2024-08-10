{ inputs, ... }:
{
  vscode-server = inputs.vscode-server.nixosModules.default;
  nixvirt = inputs.nixvirt.nixosModules.default;
  home-assistant = import ./home-assistant;
}
