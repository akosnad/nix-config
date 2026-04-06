let
  flake.modules.homeManager.vscode-server =
    { pkgs, ... }:
    {
      services.vscode-server = {
        enable = true;
        enableFHS = true;
        nodejsPackage = pkgs.nodejs_22;
        installPath = [
          "$HOME/.vscode-server"
          "$HOME/.vscode-remote-containers"
        ];
      };
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.vscode-server ];
in
{
  inherit flake;
}
