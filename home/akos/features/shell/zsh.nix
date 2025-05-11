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

  programs.fzf.enable = true;

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
}
