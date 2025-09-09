{ pkgs, ... }:
{
  services.home-assistant = {
    customComponents = with pkgs.home-assistant-custom-components; [
      bkk-stop
    ];
    config.sensor = [{
      platform = "bkk_stop";
      apiKey = "!secret bkk_api_key";
      name = "!secret bkk_stop_name";
      stopId = "!secret bkk_stop_id";
      minsAfter = 240;
      ignoreNow = false;
    }];

    config.rest_command = {
      get_akos_leave_for_work_plan = {
        method = "GET";
        url = "!secret get_akos_leave_for_work_plan_url";
        headers = { accept = "application/json"; };
      };
    };
  };
}
