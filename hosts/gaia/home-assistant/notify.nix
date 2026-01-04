let
  machines = [
    "kratos"
    "athena"
  ];
  mkNixMachineNotify = hostName: {
    command_topic = "${hostName}_notify";
    availability = [{
      topic = "${hostName}_availability";
    }];
    name = "${hostName} NixOS notify";
    qos = 1;
    default_entity_id = "${hostName}_nixos_notify";
    unique_id = "${hostName}_nixos_notify";
  };
in
{
  services.home-assistant.config = {
    mqtt.notify = map mkNixMachineNotify machines;

    notify = [
      {
        platform = "group";
        name = "Ákos notify";
        services = [
          { service = "kratos"; }
          { service = "mobile_app_harpokrates"; }
        ] ++ (map (hostName: { service = "${hostName}_notify"; }) machines);
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
