{ config, ... }:
{
  # TODO: turn off displays after 30sec
  # this seems not yet possible with cage (?)
  # see: https://github.com/cage-kiosk/cage/issues/245

  users.extraUsers.greeter = {
    home = "/tmp/greetd-home";
    createHome = true;
  };

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" "-m" "last" ];
    settings = {
      # background.path = lib.mkForce "";
      appearance.greeting_msg = "";
      widget.clock = {
        format = "%Y. %m. %d. %H:%M";
        timezone = config.time.timeZone;
      };
    };
  };

  # TODO: 
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
}
