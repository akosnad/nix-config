{
  config.flake.modules.nixos."hosts/athena" = {
    home-manager.sharedModules = [
      {
        monitors = [
          {
            name = "eDP-1";
            model = "0x0555";
            width = 1536;
            height = 1024;
            scale = 1.0;
            x = 0;
            workspace = "1";
            primary = true;
          }
        ];
      }
    ];
  };
}
