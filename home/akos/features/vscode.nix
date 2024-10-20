{ pkgs, config, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    fira-code
  ];

  home.persistence."/persist/${config.home.homeDirectory}".directories = [{
    directory = ".vscode";
    method = "bindfs";
  }
    ".config/Code"];
}
