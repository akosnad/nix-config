{ inputs, pkgs, ... }: {
  imports = [
    inputs.vscode-server.homeModules.default
  ];

  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_22;
    installPath = [
      "$HOME/.vscode-server"
      "$HOME/.vscode-remote-containers"
    ];
  };
}
