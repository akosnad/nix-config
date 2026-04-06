{
  config.flake.modules.nixos.bluetooth = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];

    home-manager.sharedModules = [{
      services.blueman-applet.enable = true;
    }];
  };
}
