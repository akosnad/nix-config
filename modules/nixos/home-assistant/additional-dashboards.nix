{ lib, config, pkgs, ... }:
let
  format = pkgs.formats.yaml { };
  inherit (lib) types;

  cfg = config.services.home-assistant.additionalDashboards;
in
{
  options.services.home-assistant.additionalDashboards = lib.mkOption {
    default = null;
    description = ''
      Additional dashboards to add to Home Assistant.

      Each dashboard is will have a YAML configuration generated, and those
      will be imported to Home Assistant's lovelace configuration under `dashboards` in yaml mode.
      The attribute name will be used as the path to the dashboard.
    '';
    type = types.nullOr (types.attrsOf (types.submodule {
      freeformType = format.type;
      options = {
        path = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "URL path to dashboard";
        };

        title = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
          defaultText = "attribute name";
          description = "Title of dashboard shown in sidebar";
        };

        headerTitle = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
          defaultText = "title";
          description = ''
            Title of dashboard shown in header

            Defaults to `title`.
          '';
        };

        icon = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Icon to show in sidebar and header";
        };

        show_in_sidebar = lib.mkOption {
          type = types.bool;
          default = true;
          description = "Show dashboard in sidebar";
        };

        require_admin = lib.mkOption {
          type = types.bool;
          default = false;
          description = "Require admin access to view dashboard";
        };
      };
    }));
  };

  config =
    let
      mkDashboardConfigEntry =
        { title
        , content
        , icon
        , show_in_sidebar
        , require_admin
        ,
        }: {
          mode = "yaml";
          filename = format.generate "lovelace-${title}.yaml" content;
          inherit title icon show_in_sidebar require_admin;
        };

      mkDashboard = name:
        let
          dashboard = cfg.${name};
          dashboardContent = builtins.removeAttrs dashboard [
            "icon"
            "show_in_sidebar"
            "require_admin"
            "headerTitle"
            "path"
          ];
          path = "lovelace-${name}";
        in
        {
          name = path;
          value = mkDashboardConfigEntry {
            title = dashboard.title or name;
            inherit (dashboard) icon show_in_sidebar require_admin;
            content = dashboardContent;
          };
        };

      dashboardNames = if cfg != null then builtins.attrNames cfg else [ ];
      dashboardList = map mkDashboard dashboardNames;
    in
    lib.mkIf (cfg != null) {
      services.home-assistant.config.lovelace.dashboards = builtins.listToAttrs dashboardList;
    };
}
