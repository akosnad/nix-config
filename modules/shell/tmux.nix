{
  config.flake.modules.homeManager.shell = {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      escapeTime = 150;
    };
  };
}
