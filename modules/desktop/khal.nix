{
  flake.modules.homeManager.desktop = {
    programs.khal = {
      enable = true;
      locale.weeknumbers = "left";
    };

    programs.khard = {
      enable = true;
    };
  };
}
