let
  flake.modules.homeManager.gh = {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    sops.wrapped-commands.gh = {
      secrets.gh-auth-token = "GH_TOKEN";
    };

    home.persistence."/persist".files = [ ".config/gh/hosts.yml" ];
  };

  flake.modules.homeManager.dev.imports = [ flake.modules.homeManager.gh ];
in
{
  inherit flake;
}
