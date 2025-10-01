{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf hasAttr;

  enable = config.wsl.enable && hasAttr "akos" config.users.users;

  npiperelay = pkgs.fetchurl rec {
    pname = "npiperelay";
    version = "1.8.0";

    url = "https://github.com/albertony/${pname}/releases/download/v${version}/npiperelay_windows_amd64.exe";
    hash = "sha256-3EbHkJHZ8tT4sQ6piA6m5bnxyBpYd9wH7dMhAhPUnl8=";

    executable = true;
  };

  gpgAgentBridgeScript = pkgs.writeShellApplication {
    name = "wsl-gpg-agent-bridge";
    runtimeInputs = with pkgs; [ gnused ];
    text = ''
      # we deliberately want to have the single-quoted string here, as it is an argument to powershell,
      # thus it shall not be parsed by bash here. running powershell directly here is possible due to WSL's
      # binfmt handler to run windows host binaries.
      # shellcheck disable=SC2016
      win_appdata="$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'echo $env:appdata')"
      win_appdata="$(tr -d '\r' <<< "$win_appdata")"
      socket_path="$win_appdata"/../Local/gnupg/S.gpg-agent.extra

      /run/npiperelay -ep -ei -s -a "$socket_path"
    '';
  };

  gpgCliWrapper = pkgs.writeShellScriptBin "gpg" ''
    gpg.exe $@
  '';
in
{
  config = mkIf enable {
    system.activationScripts.setupWindowsGpgBridge = /* bash */ ''
      # we deliberately want to have the single-quoted string here, as it is an argument to powershell,
      # thus it shall not be parsed by bash here. running powershell directly here is possible due to WSL's
      # binfmt handler to run windows host binaries.
      # shellcheck disable=SC2016
      win_appdata="$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'echo $env:appdata')"
      win_appdata="$(${lib.getExe pkgs.gnused} 's%^\(.\)\:\\%/mnt/\L\1/%; s%\\%/%g' <<< "$win_appdata" | tr -d '\r')"
      echo installing npiperelay to "$win_appdata"
      npiperelay_win_path="$win_appdata"/npiperelay/npiperelay.exe
      install -D ${npiperelay} "$npiperelay_win_path"
      ln -sf "$npiperelay_win_path" /run/npiperelay
    '';

    systemd.user = {
      sockets = {
        gpg-agent = lib.mkForce {
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "%t/gnupg/S.gpg-agent";
            SocketMode = "0600";
            DirectoryMode = "0700";
            Accept = true;
          };
        };
        gpg-agent-ssh = lib.mkForce {
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "%t/gnupg/S.gpg-agent.ssh";
            SocketMode = "0600";
            DirectoryMode = "0700";
            Accept = true;
          };
        };
      };
      services = {
        "gpg-agent@" = {
          description = "WSL GPG agent host bridge";
          wantedBy = [ "default.target" ];
          requires = [ "gpg-agent.socket" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = lib.getExe gpgAgentBridgeScript;
            StandardInput = "socket";
          };
        };
        "gpg-agent-ssh@" = {
          description = "WSL SSH agent host bridge";
          wantedBy = [ "default.target" ];
          requires = [ "gpg-agent-ssh.socket" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "/run/npiperelay -ei -s '//./pipe/openssh-ssh-agent'";
            StandardInput = "socket";
          };
        };
      };
    };

    programs.git = {
      enable = true;
      config = {
        gpg.program = lib.getExe gpgCliWrapper;
      };
    };

    environment.systemPackages = [ gpgCliWrapper ];
  };
}
