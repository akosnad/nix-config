{
  imports = [
    ./theme.nix
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        line-number = "relative";
      };
      keys.normal = {
        space.w = ":w";
        space.q = ":q";
        space.space = ":format";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };
}
