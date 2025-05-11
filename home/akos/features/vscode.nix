{ pkgs, config, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.persistence."/persist/${config.home.homeDirectory}".directories = [
    {
      directory = ".vscode";
      method = "bindfs";
    }
    ".config/Code"
  ];

  # TODO: can't install settings.json unter /persist
  stylix.targets.vscode.enable = false;
}
