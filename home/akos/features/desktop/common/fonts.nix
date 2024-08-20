{ pkgs, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "RecMono Linear Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "Recursive" ]; };
    };
    regular = {
      family = "Recursive Sans Linear Static";
      package = pkgs.recursive;
    };
  };
}
