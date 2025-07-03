{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) literalExpression mkOption types;

  supportedBrowsers = [
    "microsoft-edge"
  ];

  browserModule =
    defaultPkg: name: visible:
    let
      browser = (builtins.parseDrvName defaultPkg.name).name;
    in
    {
      enable = mkOption {
        inherit visible;
        type = types.bool;
        default = false;
        example = true;
        description = "Whether to enable ${name}.";
      };

      package = mkOption {
        inherit visible;
        type = types.package;
        default = defaultPkg;
        defaultText = literalExpression "pkgs.${browser}";
        description = "The ${name} package to use.";
      };

      commandLineArgs = mkOption {
        inherit visible;
        type = types.listOf types.str;
        default = [ ];
        example = [
          "--enable-logging=stderr"
          "--ignore-gpu-blocklist"
        ];
        description = ''
          List of command-line arguments to be passed to ${name}.

          For a list of common switches, see
          [Chrome switches](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/common/chrome_switches.cc).

          To search switches for other components, see
          [Chromium codesearch](https://source.chromium.org/search?q=file:switches.cc&ss=chromium%2Fchromium%2Fsrc).
        '';
      };
      nativeMessagingHosts = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression ''
          [
            pkgs.kdePackages.plasma-browser-integration
          ]
        '';
        description = ''
          List of ${name} native messaging hosts to install.
        '';
      };
    };

  browserConfig =
    cfg:
    let

      drvName = (builtins.parseDrvName cfg.package.name).name;
      browser = if drvName == "ungoogled-chromium" then "chromium" else drvName;
      configDir = "${config.xdg.configHome}/${browser}";

      nativeMessagingHostsJoined = pkgs.symlinkJoin {
        name = "${drvName}-native-messaging-hosts";
        paths = cfg.nativeMessagingHosts;
      };

      package =
        if cfg.commandLineArgs != [ ] then
          cfg.package.override
            {
              commandLineArgs = lib.concatStringsSep " " cfg.commandLineArgs;
            }
        else
          cfg.package;

    in
    lib.mkIf cfg.enable {
      home.packages = [ package ];
      home.file = {
        "${configDir}/NativeMessagingHosts" = lib.mkIf (cfg.nativeMessagingHosts != [ ]) {
          source = "${nativeMessagingHostsJoined}/etc/chromium/native-messaging-hosts";
          recursive = true;
        };
      };
    };

in
{
  options.programs = {
    microsoft-edge = browserModule pkgs.microsoft-edge "Microsoft Edge" true;
  };

  config = lib.mkMerge (map (browser: browserConfig config.programs.${browser}) supportedBrowsers);
}
