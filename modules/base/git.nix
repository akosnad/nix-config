{
  flake.modules.homeManager.base = {
    programs.git.enable = true;
  };

  flake.modules.nixos.base = {
    programs.git.enable = true;
  };
}
