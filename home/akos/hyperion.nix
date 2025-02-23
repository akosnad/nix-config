{
  imports = [
    ./global
  ];

  systemd.user.services.urbit = {
    Unit.Description = "Urbit";
    Service = {
      WorkingDirector = "%h/src/doptug-divfes";
      ExecStart = "%h/src/doptug-divfes/.run -t --http-ip 172.17.0.1 --http-port 4398";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
