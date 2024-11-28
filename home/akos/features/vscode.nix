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
}
