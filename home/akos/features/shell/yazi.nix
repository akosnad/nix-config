{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    keymap = {
      manager.prepend_keymap = [
        { on = "<C-y>"; run = [ "plugin wl-clipboard" ]; }
      ];
    };
    plugins = {
      wl-clipboard = pkgs.fetchFromGitHub {
        owner = "grappas";
        repo = "wl-clipboard.yazi";
        rev = "c4edc4f6adf088521f11d0acf2b70610c31924f0";
        hash = "sha256-jlZgN93HjfK+7H27Ifk7fs0jJaIdnOyY1wKxHz1wX2c=";
      };
    };
  };
}
