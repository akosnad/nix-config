let
  mkNixMachineNotify = hostName: {
    command_topic = "${hostName}_notify";
    availability = [{
      topic = "${hostName}_availability";
    }];
    name = "${hostName} NixOS notify";
    qos = 1;
    object_id = "${hostName}_nixos_notify";
    unique_id = "${hostName}_nixos_notify";
  };
in
{
  services.home-assistant.config = {
    mqtt.notify = [
      (mkNixMachineNotify "kratos")
      (mkNixMachineNotify "athena")
    ];

    notify = [
      {
        platform = "group";
        name = "Ákos notify";
        services = [
          { service = "kratos"; }
          { service = "mobile_app_2312dra50g"; }
          { service = "kratos_nixos_notify"; }
          { service = "athena_nixos_notify"; }
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
}
