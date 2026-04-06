let
  flake.modules.homeManager.vscode =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode.fhs;
      };

      home.persistence."/persist".directories = [
        ".vscode"
        ".config/Code"
      ];

      # TODO: can't install settings.json unter /persist
      stylix.targets.vscode.enable = false;
    };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.vscode ];
in
{
  inherit flake;
}
