{ config, ... }:
let
  palette = config.colorscheme.palette;
in
{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "fzf" "last-working-dir" ];
    };
    envExtra = ''
      [ -f /run/secrets/cachix-auth-token ] && export CACHIX_AUTH_TOKEN="$(cat /run/secrets/cachix-auth-token)"
    '';
  };

  programs.powerline-go = {
    enable = true;
    modules = [ "ssh" "venv" "nix-shell" "cwd" "vi-mode" ];
    modulesRight = [ "exit" "perms" "git" "jobs" ];
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = "#${palette.base05}";
      "fg+" = "#${palette.base06}";
      bg = "#${palette.base00}";
      "bg+" = "#${palette.base01}";
    };
  };
}
