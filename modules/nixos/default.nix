{ inputs, ... }:
{
  vscode-server = inputs.vscode-server.nixosModules.default;
  nixvirt = inputs.nixvirt.nixosModules.default;
}
