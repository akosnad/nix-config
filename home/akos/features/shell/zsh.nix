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
      [ -f /run/secrets/gh-auth-token ] && export GH_TOKEN="$(cat /run/secrets/gh-auth-token)"
    '';
  };

  programs.powerline-go = {
    enable = true;
    modules = [ "ssh" "host" "venv" "nix-shell" "cwd" ];
    modulesRight = [ "exit" "perms" "git" "jobs" ];
    settings = {
      hostname-only-if-ssh = true;
    };
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = "-1";
      "fg+" = "#${palette.base06}";
      bg = "-1";
      "bg+" = "-1";
      hl = "#${palette.base04}";
      "hl+" = "#${palette.base06}";
      info = "#${palette.base07}";
      marker = "#${palette.base0B}";
      prompt = "#${palette.base0C}";
      spinner = "#${palette.base0B}";
      pointer = "#${palette.base0B}";
      header = "#${palette.base0E}";
    };
  };
}
