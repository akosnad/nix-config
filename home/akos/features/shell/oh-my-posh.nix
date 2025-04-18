{ pkgs, lib, config, ... }:
let
  palette = lib.mapAttrs (_: color: "#${color}") config.colorScheme.palette;
  home = config.home.homeDirectory;
  segmentCommon = {
    style = "powerline";
    leading_powerline_symbol = "";
    powerline_symbol = "";
    background = "p:bg";
    foreground = "p:fg";
  };

  mkSegment = args: segmentCommon // args;

  ompConfig = {
    version = 2;
    final_space = true;
    upgrade = {
      # note: this is not sufficient to actually disable the notice,
      # see below where the cache file is overwritten
      notice = false;
      auto = false;
    };
    console_title_template = "{{ .Shell }} in {{ .Folder }}{{ if .Env.SSH_CLIENT }} on {{ .UserName }}@{{ .HostName }}{{ end }}";
    blocks = [
      {
        type = "prompt";
        alignment = "left";
        segments = map mkSegment [
          {
            type = "session";
            template = "{{ if .SSHSession }}  {{ .HostName }} {{ end }}";
            background = "p:info_bg";
            foreground = "p:info_fg";
          }
          {
            type = "nix-shell";
            template = "{{ if eq .Type \"impure\" }} {{ end }}";
            background = "p:info_bg";
            foreground = "p:info_fg";
          }
          {
            type = "path";
            properties = {
              style = "powerlevel";
              max_width = 5;
              mapped_locations = {
                "${home}/OneDrive" = "󰏊 OneDrive";
                "${home}/Downloads" = "󱑣 Downloads";
                "${home}/src" = "  src";
                "/" = " /";
              };
            };
          }
          {
            type = "status";
            template = " {{ if gt .Code 0 }}{{ if eq .Code 148 }} {{ else }} {{ end }}{{ else }} {{ end }} ";
            background_templates = [
              "{{ if eq .Code 148 }}p:warning_bg{{ end }}" # suspended
              "{{ if gt .Code 0 }}p:error_bg{{ end }}"
            ];
            foreground_templates = [
              "{{ if eq .Code 148 }}p:warning_fg{{ end }}" # suspended
              "{{ if gt .Code 0 }}p:error_fg{{ end }}"
            ];
          }
        ];
      }
      {
        type = "rprompt";
        alignment = "right";
        segments = map mkSegment [
          {
            type = "git";
            foreground_templates = [
              "{{ if or (.Working.Changed) (.Staging.Changed) }}p:warning_fg{{ end }}"
              "{{ if or (gt .Ahead 0) (gt .Behind 0) }}p:info_fg{{ end }}"
            ];
            background_templates = [
              "{{ if or (.Working.Changed) (.Staging.Changed) }}p:warning_bg{{ end }}"
              "{{ if or (gt .Ahead 0) (gt .Behind 0) }}p:info_bg{{ end }}"
            ];
            template = " {{ if .UpstreamURL }}{{ url .UpstreamIcon .UpstreamURL }} {{ end }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }} ";
            properties = {
              branch_max_length = 16;
              fetch_status = true;
              fetch_upstream_icon = true;
            };
          }
          {
            type = "text";
            template = "{{ if gt (int .Env.BGJOBS) 0}} 󰔛 {{ .Env.BGJOBS }}{{ end }}";
          }
        ];
      }
    ];
    transient_prompt = {
      template = "<p:bg,transparent></><,p:bg> {{ .Segments.Path.Path }} </><p:bg,transparent></> ";
      background = "transparent";
      foreground = "p:fg_faded";
    };
    palette = with palette; {
      bg = base02;
      fg = base06;
      fg_faded = base05;
      info_bg = base0D;
      info_fg = base00;
      warning_bg = base0A;
      warning_fg = base00;
      error_bg = base08;
      error_fg = base00;
    };
  };

  configPath = "${config.xdg.configHome}/../${config.xdg.configFile.oh-my-posh.target}";
in
{
  home.packages = with pkgs; [ oh-my-posh ];

  programs.zsh.initExtra = lib.mkIf config.programs.zsh.enable /* zsh */ ''
    eval "$(oh-my-posh init zsh --config "${configPath}")"
    function set_poshcontext() {
      export BGJOBS="$(jobs | wc -l | xargs)"
    }
  '';

  programs.bash.bashrcExtra = lib.mkIf config.programs.bash.enable /* bash */ ''
    eval "$(oh-my-posh init bash --config "${configPath}")"
    function set_poshcontext() {
      export BGJOBS="$(jobs | wc -l | xargs)"
    }
  '';

  xdg.configFile.oh-my-posh = {
    target = "oh-my-posh.json";
    text = builtins.toJSON ompConfig;
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
}
