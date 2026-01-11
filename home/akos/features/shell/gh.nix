{
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
}
