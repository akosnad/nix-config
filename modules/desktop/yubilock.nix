{ lib, ... }:
{
  config.flake.modules.homeManager.desktop =
    { pkgs, ... }:
    let
      # originally adapted from: https://github.com/guttermonk/yubilock
      # the idea credits them! :)
      yubilock = pkgs.rustPlatform.buildRustPackage rec {
        pname = "yubilock";
        version = "0.1.0";
        src = ./_yubilock;
        cargoLock.lockFile = ./_yubilock/Cargo.lock;
        doCheck = false;
        meta.mainProgram = pname;
      };
    in
    {
      systemd.user.services.yubilock = {
        Unit = {
          Description = "Yubikey presence locking daemon";
          After = "graphical-session-pre.target";
          Before = "waybar.service";
        };
        Service = {
          ExecStart = lib.getExe yubilock;
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
