{
  flake.modules.nixos.home-assistant = {
    services.home-assistant.config = {
      notify = [
        {
          platform = "group";
          name = "Ákos notify";
          services = [
            { service = "kratos"; }
            { service = "athena"; }
            { service = "mobile_app_harpokrates"; }
          ];
        }
        {
          platform = "group";
          name = "Mindenki";
          services = [
            { service = "akos_notify"; }
            { service = "mobile_app_kazirnp"; }
            { service = "mobile_app_anirnp"; }
          ];
        }
      ];
    };
  };
}
