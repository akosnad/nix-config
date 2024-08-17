{ pkgs, lib, ... }:
{
  systemd.user.services.yubikey-touch-detector = {
    Unit = {
      Description = "YubiKey Touch Detector";
      Requires = [ "yubikey-touch-detector.socket" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.yubikey-touch-detector}";
      Environment = [
        "YUBIKEY_TOUCH_DETECTOR_VERBOSE=false"
        "YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=false"
        "YUBIKEY_TOUCH_DETECTOR_STDOUT=false"
        "YUBIKEY_TOUCH_DETECTOR_NOSOCKET=false"
      ];
    };
    Install = {
      Also = [ "yubikey-touch-detector.socket" ];
      WantedBy = [ "default.target" ];
    };
  };
  systemd.user.sockets.yubikey-touch-detector = {
    Unit.Description = "YubiKey Touch Detector Socket activation";
    Socket = {
      ListenStream = "%t/yubikey-touch-detector.socket";
      RemoveOnStop = "yes";
    };
    Install.WantedBy = [ "sockets.target" ];
  };
}
