{ pkgs, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Terminess Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "Terminus" ]; };
    };
    regular = {
      family = "Terminus";
      package = pkgs.terminus_font;
    };
  };
}
