{ config, lib, pkgs, ... }:
let
  cfg = config.programs.oh-my-posh;
in
{
  options.programs.oh-my-posh = { };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ oh-my-posh ];

    programs.zsh.initExtra = lib.mkIf config.programs.zsh.enable /* zsh */ ''
      function set_poshcontext() {
        export BGJOBS="$(jobs | wc -l | xargs)"
      }
    '';

    programs.bash.bashrcExtra = lib.mkIf config.programs.bash.enable /* bash */ ''
      function set_poshcontext() {
        export BGJOBS="$(jobs | wc -l | xargs)"
      }
    '';

    programs.oh-my-posh.settings = {
      version = 2;
      upgrade = {
        # note: this is not sufficient to actually disable the notice,
        # see below where the cache file is overwritten
        notice = false;
        auto = false;
      };
    };

    home.file.".cache/oh-my-posh/omp.cache" = {
      # safe to forcibly overwrite
      # nothing important is stored here
      force = true;

      text = builtins.toJSON {
        # disables update check and notice by setting the TTL to -1,
        # this is what the `oh-my-posh disable notice` command does
        upgrade_check = {
          timestamp = 0;
          ttl = -1;
          value = "disabled";
        };

        # rest here is needed to function
        environment_platform = {
          timestamp = 0;
          ttl = -1;
          value = "nixos";
        };
        is_wsl = {
          timestamp = 0;
          ttl = -1;
          value = "false";
        };
      };
    };
  };
}
