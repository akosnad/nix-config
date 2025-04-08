{ config, ... }:
let
  inherit (config.colorscheme) palette;
in
{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "fzf" "last-working-dir" ];
    };
    shellAliases = {
      tree = "eza -l --tree";
    };
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = "-1";
      "fg+" = "#${palette.base06}";
      bg = "-1";
      "bg+" = "-1";
      hl = "#${palette.base04}";
      "hl+" = "#${palette.base06}";
      info = "#${palette.base07}";
      marker = "#${palette.base0B}";
      prompt = "#${palette.base0C}";
      spinner = "#${palette.base0B}";
      pointer = "#${palette.base0B}";
      header = "#${palette.base0E}";
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
}
