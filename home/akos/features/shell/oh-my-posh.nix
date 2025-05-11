{ config, ... }:
let
  home = config.home.homeDirectory;
  segmentCommon = {
    style = "powerline";
    leading_powerline_symbol = "";
    powerline_symbol = "";
    background = "p:bg";
    foreground = "p:fg";
  };

  mkSegment = args: segmentCommon // args;
in
{
  programs.oh-my-posh = {
    enable = true;
    settings = {
      final_space = true;
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
    };
  };
}
