{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "fzf" "last-working-dir" ];
    };
    shellAliases = {
      tree = "eza -l --tree";
      t = "eza -al --tree --git-ignore --git-repos --color=always --icons=always | less -rF";
      y = "yazi";
      nd = "nix develop -c $SHELL";
    };
  };

  programs.fzf.enable = true;

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
}
