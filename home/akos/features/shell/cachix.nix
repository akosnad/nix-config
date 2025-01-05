{ pkgs, config, ... }:
let
  tokenPath = config.sops.secrets.cachix-auth-token.path;

  loadScript = ''
    [ -f "${tokenPath}" ] && export CACHIX_AUTH_TOKEN="$(cat "${tokenPath}")"
  '';
in
{
  home.packages = [ pkgs.cachix ];

  sops.secrets = {
    cachix-auth-token = { };
  };

  programs.zsh.envExtra = loadScript;
  programs.bash.initExtra = loadScript;
}
