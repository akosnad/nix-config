{
  flake.modules.homeManager.desktop = {
    programs.glide-browser = {
      enable = true;
      profiles = {
        personal = {
          settings."extensions.autoDisableScopes" = 0;
          extensions.force = true;
        };
        alt.id = 1;
      };
    };

    stylix.targets.glide-browser = {
      colorTheme.enable = true;
      profileNames = [ "personal" ];
    };

    home.persistence."/persist".directories = [
      ".config/glide"
      ".cache/glide"
    ];
  };
}
