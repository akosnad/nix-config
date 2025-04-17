{ pkgs, lib, ... }:
let
  # originally adapted from: https://github.com/guttermonk/yubilock
  # the idea credits them! :)
  yubilock = pkgs.rustPlatform.buildRustPackage rec {
    pname = "yubilock";
    version = "0.1.0";
    src = ./.;
    cargoLock.lockFile = ./Cargo.lock;
    doCheck = false;
    meta.mainProgram = pname;
  };
in
{
  systemd.user.services.yubilock = {
    Unit = {
      Description = "Yubikey presence locking daemon";
      After = "graphical-session.target";
      Before = "waybar.service";
    };
    Service = {
      ExecStart = lib.getExe yubilock;
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
