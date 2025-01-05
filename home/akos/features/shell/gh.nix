{ config, ... }:
let
  tokenPath = config.sops.secrets.gh-auth-token.path;

  loadScript = ''
    [ -f "${tokenPath}" ] && export GH_TOKEN="$(cat "${tokenPath}")"
  '';
in
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  sops.secrets = {
    gh-auth-token = { };
  };

  programs.zsh.envExtra = loadScript;
  programs.bash.initExtra = loadScript;

  home.persistence."/persist/${config.home.homeDirectory}".files = [ ".config/gh/hosts.yml" ];
}
