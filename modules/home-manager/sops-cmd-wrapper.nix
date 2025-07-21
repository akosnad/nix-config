{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.sops;

  wrappedCmdModule = { config, name, ... }: {
    options = {
      package = mkOption {
        type = types.package;
        description = "Package to wrap";
        default = pkgs.${name};
      };
      exe = mkOption {
        type = types.str;
        description = "Name of executable in package to wrap";
        default = name;
      };
      secrets = mkOption {
        type = types.attrsOf types.str;
        description = ''
          sops secrets to export as environment variables to the command.
        '';
        example = {
          github-token = "GH_TOKEN";
        };
      };
      sopsFile = mkOption {
        type = types.path;
        description = "sops file to pull secrets from";
        default = cfg.sopsFile;
      };
      zshInit = mkOption {
        type = types.str;
        internal = true;
      };
    };
    config =
      let
        mkSecretExport = secretName: envVarName: /* zsh */ ''
          if [[ -z "''$${envVarName}" ]]; then
            export ${envVarName}="$(${lib.getExe pkgs.sops} decrypt --extract '["${secretName}"]' ${config.sopsFile})"
          fi
        '';
      in
      {
        zshInit = /* zsh */ ''
          function ${name}() {
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkSecretExport config.secrets)}
            unfunction ${name}
            command ${lib.getExe' config.package config.exe} "$@"
          }
          autoload -Uz ${name}
        '';
      };
  };
in
{
  options.sops = {
    wrapped-commands = mkOption {
      type = types.attrsOf (types.submodule wrappedCmdModule);
      default = { };
    };
    sopsFile = mkOption {
      type = types.path;
    };
  };
  config = {
    programs.zsh.initContent = /* zsh */ lib.concatStringsSep "\n" (lib.pipe cfg.wrapped-commands [
      (lib.mapAttrsToList (_: v: v.zshInit))
    ]);
    home.packages = lib.mapAttrsToList (_: v: v.package) cfg.wrapped-commands;
  };
}
